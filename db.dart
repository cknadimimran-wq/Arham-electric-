import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class AppDb {
  AppDb._(); static final instance=AppDb._(); Database? _db; final uuid=const Uuid();
  Future<void> init() async {
    final p=join(await getDatabasesPath(),'arham_electric.db');
    _db=await openDatabase(p,version:1,onCreate:(db,v)async{
      await db.execute("create table products(id text primary key,name text,buy_price real,sell_price real,stock integer,created_at text)");
      await db.execute("create table sales(id text primary key,product_id text,quantity integer,buy_total real,sell_total real,profit real,payment_type text,created_at text)");
      await db.execute("create table customers(id text primary key,name text,phone text,address text,due real,created_at text)");
    });
  }
  Database get db=>_db!;
  Future<List<Map<String,dynamic>>> products(String q)=>db.query('products',
    where:q.isEmpty?null:'name like ?',whereArgs:q.isEmpty?null:['%$q%'],orderBy:'name');
  Future<void> addProduct(String n,double b,double s,int q)=>db.insert('products',{
    'id':uuid.v4(),'name':n.trim(),'buy_price':b,'sell_price':s,'stock':q,'created_at':DateTime.now().toIso8601String()});
  Future<void> addSale(String productId,int qty,String payment) async {
    await db.transaction((tx)async{
      final r=await tx.query('products',where:'id=?',whereArgs:[productId],limit:1);
      if(r.isEmpty || (r.first['stock'] as int)<qty)throw Exception('স্টক পর্যাপ্ত নেই');
      final p=r.first,b=(p['buy_price'] as num).toDouble()*qty,s=(p['sell_price'] as num).toDouble()*qty;
      await tx.insert('sales',{'id':uuid.v4(),'product_id':productId,'quantity':qty,'buy_total':b,'sell_total':s,'profit':s-b,'payment_type':payment,'created_at':DateTime.now().toIso8601String()});
      await tx.update('products',{'stock':(p['stock'] as int)-qty},where:'id=?',whereArgs:[productId]);
    });
  }
  Future<List<Map<String,dynamic>>> customers(String q)=>db.query('customers',
    where:q.isEmpty?null:'name like ? or phone like ?',whereArgs:q.isEmpty?null:['%$q%','%$q%'],orderBy:'name');
  Future<void> addCustomer(String n,String ph,String a,double due)=>db.insert('customers',{
    'id':uuid.v4(),'name':n.trim(),'phone':ph.trim(),'address':a.trim(),'due':due,'created_at':DateTime.now().toIso8601String()});
  Future<Map<String,double>> summary()async{
    final day=DateTime.now().toIso8601String().substring(0,10);
    final s=await db.rawQuery("select coalesce(sum(sell_total),0) x, coalesce(sum(profit),0) p from sales where created_at like ?",['$day%']);
    final d=await db.rawQuery("select coalesce(sum(due),0) x from customers");
    final st=await db.rawQuery("select coalesce(sum(buy_price*stock),0) x from products");
    return {'sales':(s.first['x'] as num).toDouble(),'profit':(s.first['p'] as num).toDouble(),
      'due':(d.first['x'] as num).toDouble(),'stock':(st.first['x'] as num).toDouble()};
  }
}

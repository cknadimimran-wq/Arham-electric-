import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDb.instance.init();
  runApp(const ArhamElectricApp());
}

class ArhamElectricApp extends StatelessWidget {
  const ArhamElectricApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'আরহাম ইলেকট্রিক',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final u=TextEditingController(), p=TextEditingController(), c=TextEditingController();
  bool busy=false;
  Future<void> login() async {
    setState(()=>busy=true);
    final prefs=await SharedPreferences.getInstance();
    final activated=prefs.getBool('activated')??false;
    if(!activated && c.text.trim().isEmpty){
      setState(()=>busy=false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('প্রথমবার Activation Code দিন।')));
      return;
    }
    if(!activated) await prefs.setBool('activated',true);
    if(mounted) Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const DashboardPage()));
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),
      child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:430),
        child:Column(children:[
          Image.asset('assets/arham_logo.png',height:170),
          const SizedBox(height:14),
          const Text('আরহাম ইলেকট্রিক',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),
          const SizedBox(height:22),
          TextField(controller:u,decoration:const InputDecoration(labelText:'Username')),
          const SizedBox(height:12),
          TextField(controller:p,obscureText:true,decoration:const InputDecoration(labelText:'Password')),
          const SizedBox(height:12),
          TextField(controller:c,obscureText:true,decoration:const InputDecoration(labelText:'Activation Code')),
          const SizedBox(height:18),
          FilledButton(onPressed:busy?null:login,
            child:SizedBox(width:double.infinity,child:Center(child:Text(busy?'অপেক্ষা করুন...':'Login'))))
        ]))))
  );
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override State<DashboardPage> createState()=>_DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage>{
  int tab=0;
  final pages=const[HomeTab(),ProductsTab(),SalesTab(),CustomersTab(),ReportsTab()];
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('আরহাম ইলেকট্রিক')),
    body:pages[tab],
    bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),
      destinations:const[
        NavigationDestination(icon:Icon(Icons.dashboard),label:'হোম'),
        NavigationDestination(icon:Icon(Icons.inventory_2),label:'স্টক'),
        NavigationDestination(icon:Icon(Icons.point_of_sale),label:'বিক্রি'),
        NavigationDestination(icon:Icon(Icons.people),label:'বাকি'),
        NavigationDestination(icon:Icon(Icons.assessment),label:'রিপোর্ট'),
      ]),
  );
}

class HomeTab extends StatefulWidget{const HomeTab({super.key});@override State<HomeTab> createState()=>_HomeTabState();}
class _HomeTabState extends State<HomeTab>{
  Map<String,double> s={};
  @override void initState(){super.initState();load();}
  Future<void> load()async{s=await AppDb.instance.summary();if(mounted)setState((){});}
  @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(16),children:[
    Wrap(spacing:12,runSpacing:12,children:[
      Stat('আজকের বিক্রি','৳ ${(s['sales']??0).toStringAsFixed(2)}',Icons.point_of_sale),
      Stat('আজকের লাভ','৳ ${(s['profit']??0).toStringAsFixed(2)}',Icons.trending_up),
      Stat('মোট বাকি','৳ ${(s['due']??0).toStringAsFixed(2)}',Icons.account_balance_wallet),
      Stat('স্টক মূল্য','৳ ${(s['stock']??0).toStringAsFixed(2)}',Icons.inventory),
    ]),
    const SizedBox(height:18),
    const Card(child:ListTile(leading:Icon(Icons.sync),title:Text('Offline-first'),
      subtitle:Text('ইন্টারনেট না থাকলেও লোকাল ডাটাবেসে কাজ চলবে। Cloud Sync পরের ধাপে যুক্ত হবে।')))
  ]));
}
class Stat extends StatelessWidget{
  final String title,value;final IconData icon;
  const Stat(this.title,this.value,this.icon,{super.key});
  @override Widget build(BuildContext context)=>SizedBox(width:170,height:120,child:Card(child:Padding(
    padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Icon(icon),const Spacer(),Text(title),Text(value,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold))
    ]))));
}

class ProductsTab extends StatefulWidget{const ProductsTab({super.key});@override State<ProductsTab> createState()=>_ProductsTabState();}
class _ProductsTabState extends State<ProductsTab>{
  List<Map<String,dynamic>> rows=[];final search=TextEditingController();
  @override void initState(){super.initState();load();}
  Future<void> load()async{rows=await AppDb.instance.products(search.text);if(mounted)setState((){});}
  Future<void> add()async{
    final n=TextEditingController(),b=TextEditingController(),s=TextEditingController(),q=TextEditingController();
    await showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('নতুন পণ্য'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:n,decoration:const InputDecoration(labelText:'পণ্যের নাম')),
        const SizedBox(height:8),TextField(controller:b,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'কেনা দাম')),
        const SizedBox(height:8),TextField(controller:s,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'বিক্রি দাম')),
        const SizedBox(height:8),TextField(controller:q,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'পরিমাণ')),
      ]),
      actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('বাতিল')),
        FilledButton(onPressed:()async{await AppDb.instance.addProduct(n.text,double.tryParse(b.text)??0,double.tryParse(s.text)??0,int.tryParse(q.text)??0);if(context.mounted)Navigator.pop(context);load();},child:const Text('সংরক্ষণ'))]));
  }
  @override Widget build(BuildContext context)=>Column(children:[
    Padding(padding:const EdgeInsets.all(12),child:Row(children:[
      Expanded(child:TextField(controller:search,onChanged:(_)=>load(),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'পণ্য খুঁজুন'))),
      IconButton(onPressed:add,icon:const Icon(Icons.add_box,size:30))
    ])),
    Expanded(child:ListView.builder(itemCount:rows.length,itemBuilder:(c,i){final x=rows[i];return Card(child:ListTile(
      title:Text(x['name']),subtitle:Text('কেনা: ৳${x['buy_price']} | বিক্রি: ৳${x['sell_price']}'),
      trailing:Text('স্টক ${x['stock']}',style:const TextStyle(fontWeight:FontWeight.bold))));}))
  ]);
}

class SalesTab extends StatefulWidget{const SalesTab({super.key});@override State<SalesTab> createState()=>_SalesTabState();}
class _SalesTabState extends State<SalesTab>{
  List<Map<String,dynamic>> products=[];
  @override void initState(){super.initState();load();}
  Future<void> load()async{products=await AppDb.instance.products('');if(mounted)setState((){});}
  Future<void> sell(Map<String,dynamic> p)async{
    final q=TextEditingController(text:'1');String type='cash';
    await showDialog(context:context,builder:(_)=>StatefulBuilder(builder:(ctx,setLocal)=>AlertDialog(
      title:Text('${p['name']} বিক্রি'),content:Column(mainAxisSize:MainAxisSize.min,children:[
        Text('বিক্রির দাম: ৳${p['sell_price']}'),const SizedBox(height:10),
        TextField(controller:q,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'পরিমাণ')),
        DropdownButton<String>(value:type,isExpanded:true,items:const[
          DropdownMenuItem(value:'cash',child:Text('নগদ')),DropdownMenuItem(value:'due',child:Text('বাকি'))],
          onChanged:(v)=>setLocal(()=>type=v!))
      ]),actions:[FilledButton(onPressed:()async{final qty=int.tryParse(q.text)??0;if(qty<=0)return;await AppDb.instance.addSale(p['id'],qty,type);if(ctx.mounted)Navigator.pop(ctx);load();},child:const Text('বিক্রি করুন'))])));
  }
  @override Widget build(BuildContext context)=>ListView.builder(padding:const EdgeInsets.all(12),itemCount:products.length,itemBuilder:(c,i){
    final p=products[i];return Card(child:ListTile(title:Text(p['name']),subtitle:Text('স্টক: ${p['stock']} | বিক্রি: ৳${p['sell_price']}'),
      trailing:FilledButton(onPressed:p['stock']>0?()=>sell(p):null,child:const Text('বিক্রি'))));
  });
}

class CustomersTab extends StatefulWidget{const CustomersTab({super.key});@override State<CustomersTab> createState()=>_CustomersTabState();}
class _CustomersTabState extends State<CustomersTab>{
  List<Map<String,dynamic>> rows=[];final q=TextEditingController();
  @override void initState(){super.initState();load();}
  Future<void> load()async{rows=await AppDb.instance.customers(q.text);if(mounted)setState((){});}
  Future<void> add()async{
    final n=TextEditingController(),ph=TextEditingController(),a=TextEditingController(),d=TextEditingController();
    await showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('বাকি কাস্টমার'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:n,decoration:const InputDecoration(labelText:'নাম')),const SizedBox(height:8),
      TextField(controller:ph,decoration:const InputDecoration(labelText:'মোবাইল')),const SizedBox(height:8),
      TextField(controller:a,decoration:const InputDecoration(labelText:'ঠিকানা')),const SizedBox(height:8),
      TextField(controller:d,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'বাকি টাকা'))
    ]),actions:[FilledButton(onPressed:()async{await AppDb.instance.addCustomer(n.text,ph.text,a.text,double.tryParse(d.text)??0);if(context.mounted)Navigator.pop(context);load();},child:const Text('সংরক্ষণ'))]));
  }
  @override Widget build(BuildContext context)=>Column(children:[
    Padding(padding:const EdgeInsets.all(12),child:Row(children:[
      Expanded(child:TextField(controller:q,onChanged:(_)=>load(),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),labelText:'নাম/মোবাইল সার্চ'))),
      IconButton(onPressed:add,icon:const Icon(Icons.person_add,size:30))
    ])),
    Expanded(child:ListView.builder(itemCount:rows.length,itemBuilder:(c,i){final x=rows[i];return Card(child:ListTile(
      title:Text(x['name']),subtitle:Text('${x['phone']??''}\n${x['address']??''}'),isThreeLine:true,trailing:Text('৳${x['due']}')));}))
  ]);
}

class ReportsTab extends StatelessWidget{
  const ReportsTab({super.key});
  @override Widget build(BuildContext context)=>FutureBuilder<Map<String,double>>(future:AppDb.instance.summary(),builder:(c,s){
    final x=s.data??{};return ListView(padding:const EdgeInsets.all(16),children:[
      const Text('হিসাবের সারাংশ',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
      const SizedBox(height:12),Card(child:Column(children:[
        ListTile(title:const Text('আজকের মোট বিক্রি'),trailing:Text('৳${(x['sales']??0).toStringAsFixed(2)}')),
        ListTile(title:const Text('আজকের মোট লাভ'),trailing:Text('৳${(x['profit']??0).toStringAsFixed(2)}')),
        ListTile(title:const Text('মোট বাকি'),trailing:Text('৳${(x['due']??0).toStringAsFixed(2)}')),
        ListTile(title:const Text('বর্তমান স্টক মূল্য'),trailing:Text('৳${(x['stock']??0).toStringAsFixed(2)}')),
      ]))
    ]);
  });
}

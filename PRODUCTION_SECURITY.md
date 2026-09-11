# Production security plan

- Every shop gets a unique shop_id (tenant).
- Username/password authenticate with a real backend.
- Activation code is verified server-side; the owner master secret is never embedded in the APK.
- Store only a salted password hash on the server.
- Every product, sale, customer and payment row includes shop_id.
- Enforce Row Level Security so one shop cannot read another shop's data.
- Offline changes go into an outbox; sync uses idempotent operation IDs and conflict handling.
- License can be activated, suspended or revoked by the owner.
- Keep an audit log for important edits/deletions.

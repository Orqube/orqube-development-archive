import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_access.dart';

class AdminOnly extends StatelessWidget {
  const AdminOnly({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.idTokenChanges(),
    builder: (context, snapshot) => FutureBuilder<bool>(
      key: ValueKey(snapshot.data?.uid),
      future: snapshot.data == null ? Future.value(false) : AdminAccess.allowed(),
      builder: (context, permission) => permission.connectionState == ConnectionState.done && permission.data == true ? child : const SizedBox.shrink(),
    ),
  );
}

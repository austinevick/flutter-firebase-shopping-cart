import 'package:flutter/material.dart';

import '../core/constant.dart';
import '../provider/authentication_service.dart';
import '../provider/firestore_service.dart';

class Userdrawer extends StatefulWidget {
  const Userdrawer({Key? key}) : super(key: key);

  @override
  State<Userdrawer> createState() => _UserdrawerState();
}

class _UserdrawerState extends State<Userdrawer> {
  final auth = AuthenticationService();
  final user = FirestoreService();
  String name = '';
  String email = '';
  Future<void> initUserData() async {
    final data = await user.getUserInfo();
    setState(() => name = data.fullname!);
    setState(() => email = data.email!);
  }

  @override
  void initState() {
    initUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 35),
        const CircleAvatar(
          radius: 45,
          child: Icon(Icons.person_outline, size: 40),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          email,
          style: style.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Divider(thickness: 1.5),
        const SizedBox(height: 10),
        const Spacer(),
        ListTile(
          onTap: () async => await auth.signout(context),
          leading: Text(
            'Take a break',
            style: style.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          trailing: const Icon(Icons.exit_to_app),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_cart/widget/badge.dart';
import '../core/constant.dart';
import '../provider/firestore_service.dart';
import '../widget/product_list.dart';
import '../widget/user_drawer.dart';
import 'add_products_screen.dart';

final userProvider =
    FutureProvider((ref) async => ref.read(firestoreProvider).getUserInfo());

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Scaffold(
        drawer: const Drawer(child: Userdrawer()),
        appBar: AppBar(
          title: const Text('Home'),
          centerTitle: true,
          actions: const [Badge()],
        ),
        body: const ProductList(),
        floatingActionButton: ref.watch(userProvider).when(
            data: (data) => data.isAdmin == true
                ? FloatingActionButton(
                    backgroundColor: primaryColor,
                    onPressed: () => push(context, const AddProductsScreen()),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
            error: (error, trace) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink()),
      );
    });
  }
}

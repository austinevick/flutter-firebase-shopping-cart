import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shopping_cart/model/product_model.dart';

import '../core/constant.dart';
import '../provider/firestore_service.dart';
import '../screen/product_cart_screen.dart';
import '../screen/product_detail_screen.dart';
import 'custom_button.dart';
import 'custom_loader.dart';

final productProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>(
    (ref) => ref.read(firestoreProvider).getProducts());

class ProductList extends ConsumerWidget {
  const ProductList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ref.read(firestoreProvider).getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemBuilder: (ctx, i) {
                final product = snapshot.data!.docs[i].data();
                return MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => showMaterialModalBottomSheet(
                      expand: true,
                      context: context,
                      builder: (ctx) => ProductDetailScreen(
                            id: product['id'].toString(),
                            docId: snapshot.data!.docs[i].id,
                            image: product['image'],
                            price: product['price'],
                            quantity: product['quantity'],
                            name: product['name'],
                          )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(product['image']),
                              )),
                          child: Container(
                            width: double.infinity,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                )),
                            child: Column(
                              children: [
                                const Spacer(),
                                Text(
                                  product['name'],
                                  style: style.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\$${product['price']}',
                                  style: style.copyWith(
                                    fontSize: 15,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: snapshot.data!.docs.length);
        });
  }
}

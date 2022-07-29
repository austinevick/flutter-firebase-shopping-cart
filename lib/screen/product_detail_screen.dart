import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constant.dart';
import '../model/product_model.dart';
import '../provider/firestore_service.dart';
import '../widget/custom_button.dart';
import '../widget/custom_loader.dart';
import 'product_cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? id;
  final String? name;
  final String? image;
  final num? price;
  final String? docId;
  final String? desc;
  final String? category;
  final bool? favourite;
  final int? quantity;
  const ProductDetailScreen(
      {Key? key,
      this.id,
      this.docId,
      this.name,
      this.image,
      this.price,
      this.desc,
      this.category,
      this.favourite,
      this.quantity})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  num? get cost => widget.price! * quantity;
  bool isAlreadyInCart = false;
  bool isLoading = false;

  Future<void> addToCart(WidgetRef ref) async {
    final products = ProductModel(
        id: widget.docId,
        image: widget.image,
        name: widget.name,
        quantity: quantity,
        price: cost,
        desc: widget.desc,
        favourite: widget.favourite);
    try {
      setState(() => isLoading = true);
      final reference =
          await ref.watch(firestoreProvider).addProductsToCart(products);
      if (reference.id.isNotEmpty) {
        setState(() => isAlreadyInCart = true);
      }
      setState(() => isLoading = false);
    } on FirebaseException catch (e) {
      setState(() => isLoading = false);
      showSnackbar(context, e.message!);
      rethrow;
    } catch (_) {
      setState(() => isLoading = false);
      showSnackbar(context, unknownError);
      rethrow;
    }
  }

  void getProductId() {
    final docSnapshot = FirestoreService().getProductIdFromCart(widget.docId!);
    docSnapshot.then((querySnapshot) {
      querySnapshot.docs.asMap().entries.forEach((element) {
        print('${element.value['id']} is equal to ${widget.docId}');
        if (element.value['id'] == widget.docId) {
          setState(() => isAlreadyInCart = true);
        }
      });
    });
  }

  @override
  void initState() {
    getProductId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final n = ref.read(firestoreProvider);

      return Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 450,
                child: Container(
                  alignment: Alignment.topLeft,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.image!),
                  )),
                ),
              ),
              Positioned(
                top: 25,
                left: 16,
                child: CircleAvatar(
                  child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.keyboard_backspace)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('\$${cost!.toStringAsFixed(1)}',
                    style: style.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 20)),
                const Spacer(),
                Text(
                  widget.name!,
                  style:
                      style.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Spacer(flex: 2)
              ],
            ),
          ),
          const SizedBox(height: 12),
          isAlreadyInCart
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              if (quantity <= 1) return;
                              quantity--;
                            });
                          },
                          icon: const Icon(Icons.remove)),
                    ),
                    Text(
                      quantity.toString(),
                      style: style.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: primaryColor),
                    ),
                    CircleAvatar(
                      radius: 25,
                      child: IconButton(
                          onPressed: () => setState(() => quantity++),
                          icon: const Icon(Icons.add)),
                    )
                  ],
                ),
          const Spacer(),
          CustomButton(
            color: isAlreadyInCart ? Colors.green : primaryColor,
            child: CustomLoader(
              isLoading: isLoading,
              text: !isAlreadyInCart ? 'Add to Cart' : 'Go to Cart',
            ),
            onPressed: () {
              if (isAlreadyInCart) {
                Navigator.of(context).pop();
                push(context, const ItemCartScreen());
              } else {
                addToCart(ref);
              }
            },
          ),
          CustomButton(
            text: 'Order now',
            onPressed: () {},
          ),
        ],
      );
    });
  }
}

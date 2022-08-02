import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../core/constant.dart';
import '../model/product_model.dart';
import '../provider/firestore_service.dart';
import '../screen/product_cart_screen.dart';
import 'badge.dart';
import 'custom_loader.dart';

class CartItemList extends StatefulWidget {
  final String? id;
  final String? name;
  final String? image;
  final num? price;
  final String? docId;
  final String? desc;
  final String? category;
  final bool? favourite;
  final int? quantity;
  const CartItemList(
      {Key? key,
      this.id,
      this.name,
      this.image,
      this.price,
      this.docId,
      this.desc,
      this.category,
      this.favourite,
      this.quantity})
      : super(key: key);

  @override
  State<CartItemList> createState() => _CartItemListState();
}

class _CartItemListState extends State<CartItemList> {
  bool isLoading = false;

  Future<void> removeProductFromCart(WidgetRef ref) async {
    try {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(seconds: 2),
          (() => ref.read(firestoreProvider).removeProductFromCart()));
      ref.refresh(cartFutureProvider);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.docId);
    return Consumer(builder: (context, ref, _) {
      final n = ref.read(firestoreProvider);
      return MaterialButton(
        padding: const EdgeInsets.all(0),
        onPressed: () => showMaterialModalBottomSheet(
            expand: true,
            context: context,
            builder: (ctx) => Container() //ItemDetailScreen(item: widget.model)
            ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.topRight,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.image!),
                      )),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.name!,
                        style: style.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        " (${widget.quantity.toString()}) ",
                        style: style.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${widget.price!.toStringAsFixed(1)}",
                    style: style.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 17),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 110,
                        child: OutlinedButton(
                            onPressed: () => removeProductFromCart(ref),
                            child: CustomLoader(
                                color: primaryColor,
                                isLoading: isLoading,
                                text: 'Remove')),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        width: 110,
                        child: OutlinedButton(
                            onPressed: () {}, child: const Text('Buy')),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

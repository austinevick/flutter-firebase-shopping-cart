import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/firestore_service.dart';
import '../widget/cart_item_list.dart';
import '../widget/custom_button.dart';

final cartFutureProvider = StreamProvider((ref) {
  return ref.read(firestoreProvider).getProductsFromCart();
});

class ItemCartScreen extends StatelessWidget {
  const ItemCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Scaffold(
          appBar: AppBar(title: const Text('Cart')),
          body: SafeArea(
              child: ref.watch(cartFutureProvider).when(
                  data: (cart) {
                    num totalPriceInCart = cart.fold(
                        0,
                        (num previousValue, element) =>
                            previousValue + element.price!);
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: cart.length,
                              itemBuilder: (context, i) => CartItemList(
                                    name: cart[i].name,
                                    price: cart[i].price,
                                    quantity: cart[i].quantity,
                                    image: cart[i].image,
                                  )),
                        ),
                        CustomButton(
                          onPressed: () {},
                          text:
                              'Check out \$${totalPriceInCart.toStringAsFixed(1)}',
                        )
                      ],
                    );
                  },
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ))));
    });
  }
}

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constant.dart';
import '../model/product_model.dart';
import '../provider/firestore_service.dart';
import '../widget/custom_button.dart';
import '../widget/custom_loader.dart';
import '../widget/custom_modal_bottom_sheet.dart';
import '../widget/custom_textfield.dart';

class AddProductsScreen extends StatefulWidget {
  const AddProductsScreen({Key? key}) : super(key: key);

  @override
  State<AddProductsScreen> createState() => _AddProductsScreenState();
}

class _AddProductsScreenState extends State<AddProductsScreen> {
  final key = GlobalKey<FormState>();
  final nameCtr = TextEditingController();
  final descriptionCtr = TextEditingController();
  final priceCtr = TextEditingController();
  final storage = FirebaseStorage.instance;
  final firestore = FirestoreService();
  bool isLoading = false;
  String selectedCategory = 'Select category';
  final imagePicker = ImagePicker();
  CroppedFile? image;
  String fileName = '';

  Future<void> pickImage(ImageSource source) async {
    Navigator.of(context).pop();
    try {
      XFile? pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage == null) return;
      CroppedFile? file = await cropImage(pickedImage.path);
      setState(() {
        image = file;
        fileName = path.basename(file!.path);
      });
    } catch (_) {
      showSnackbar(context, somethingWentWrong);
    }
  }

  Future<CroppedFile?> cropImage(String path) async {
    return await ImageCropper().cropImage(sourcePath: path, uiSettings: [
      AndroidUiSettings(
          toolbarColor: primaryColor, toolbarWidgetColor: Colors.white)
    ]);
  }

  Future<String> uploadProduct() async {
    try {
      setState(() => isLoading = true);
      final snapshot = await storage.ref(fileName).putFile(File(image!.path));
      if (snapshot.state == TaskState.success) {
        setState(() => isLoading = false);
        String url = await snapshot.ref.getDownloadURL();
        final products = ProductModel(
            id: DateTime.now().toIso8601String(),
            name: nameCtr.text,
            price: num.parse(priceCtr.text),
            quantity: 1,
            image: url,
            category: selectedCategory,
            favourite: false);
        await firestore.addProducts(products);
        return url;
      }
      throw Exception('');
    } on FirebaseException catch (e) {
      setState(() => isLoading = false);
      showSnackbar(context, e.message!);
      rethrow;
    } catch (e) {
      setState(() => isLoading = false);
      showSnackbar(context, e.toString());
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add product')),
      body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Form(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CustomTextfield(
                    controller: nameCtr,
                    hintText: 'Name',
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    controller: priceCtr,
                    hintText: 'Price',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                      controller: descriptionCtr, hintText: 'Description'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField(
                      decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 1.5)),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      isExpanded: true,
                      value: selectedCategory,
                      items: category
                          .map((e) => DropdownMenuItem<String>(
                              value: e, child: Text(e)))
                          .toList(),
                      onChanged: (String? val) => selectedCategory = val!),
                  const SizedBox(height: 16),
                  image == null
                      ? Container()
                      : Image.file(File(image!.path), height: 200),
                  const SizedBox(height: 16),
                  CustomButton(
                      color: Colors.black,
                      borderSide: const BorderSide(),
                      text: image == null ? 'Add image' : 'Change image',
                      onPressed: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => CustomModalBottomSheet(
                              title: 'Image source',
                              button1Text: 'Camera',
                              button2Text: 'Gallery',
                              button1OnTap: () async =>
                                  await pickImage(ImageSource.camera),
                              button2OnTap: () async =>
                                  await pickImage(ImageSource.gallery)))),
                  const SizedBox(height: 100),
                  CustomButton(
                    child:
                        CustomLoader(isLoading: isLoading, text: 'Add product'),
                    onPressed: () async => await uploadProduct().then((value) {
                      if (value.isNotEmpty) {
                        Navigator.of(context).pop();
                      }
                    }),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

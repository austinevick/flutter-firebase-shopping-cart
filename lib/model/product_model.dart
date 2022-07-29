class ProductModel {
  final String? id;
  final String? name;
  final String? image;
  final num? price;
  final String? desc;
  final String? category;
  final bool? favourite;
  int? quantity;
  ProductModel({
    this.id,
    this.name,
    this.image,
    this.price,
    this.desc,
    this.category,
    this.favourite = false,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'desc': desc,
      'category': category,
      'favourite': favourite,
      'quantity': quantity,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic>? map) {
    return ProductModel(
      id: map!['id'],
      name: map['name'],
      image: map['image'],
      price: map['price'],
      desc: map['desc'],
      category: map['category'],
      favourite: map['favourite'],
      quantity: map['quantity'],
    );
  }
}

List<String> category = [
  'Select category',
  'Flower',
  'Fruit',
  'Laptop',
  'Pizza',
  'Phone',
  'Shirt',
  'Shoe'
];

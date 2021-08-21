import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/model/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  // Future<void> addProduct(Product prod) {
  //   const url =
  //       "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/products.json";
  //   return http
  //       .post(Uri.parse(url),
  //           body: json.encode({
  //             "title": prod.title,
  //             "description": prod.description,
  //             "imageUrl": prod.imageUrl,
  //             "price": prod.price,
  //             "isFavorite": prod.isFavorite,
  //           }))
  //       .then((value) {
  //         print(json.decode(value.body));
  //         final product = Product(
  //             id: json.decode(value.body)["name"],
  //             title: prod.title,
  //             description: prod.description,
  //             price: prod.price,
  //             imageUrl: prod.imageUrl);
  //         _items.add(product);
  //         notifyListeners();
  //       })
  //       .then((value) => Future.value())
  //       .catchError((error) {
  //         throw error;
  //       });
  // }

  String? authToken;
  String? userId;

  ProductProvider();

  Future<void> addProduct(Product prod) async {
    final url =
        "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            "title": prod.title,
            "description": prod.description,
            "imageUrl": prod.imageUrl,
            "price": prod.price,
            "creatorId": this.userId,
          }));
      final product = Product(
          id: json.decode(response.body)["name"],
          title: prod.title,
          description: prod.description,
          price: prod.price,
          imageUrl: prod.imageUrl);
      _items.add(product);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterString =
        filterByUser ? "orderBy=\"creatorId\"&equalTo=\"$userId\"" : "";
    final url =
        "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final favoriteStatus = await http.get(Uri.parse(
          "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken"));
      print(
          "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken");
      final favData = json.decode(favoriteStatus.body);
      this._items.clear();
      extractedData.forEach((prodId, prodData) {
        this._items.add(Product(
              id: prodId,
              title: prodData["title"] as String,
              description: prodData["description"],
              price: prodData["price"],
              imageUrl: prodData["imageUrl"],
              isFavorite: (favData == null) ? false : favData[prodId] ?? false,
            ));
      });
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> updateProduct(String id, Product product) async {
    final productIndex = this._items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
      try {
        http.patch(Uri.parse(url),
            body: json.encode({
              "title": product.title,
              "description": product.description,
              "imageUrl": product.imageUrl,
              "price": product.price
            }));
        this._items[productIndex] = product;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken";
    final existingIndex = this._items.indexWhere((element) => element.id == id);
    Product? existingItem = this._items[existingIndex];
    this._items.removeAt(existingIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      this._items.insert(existingIndex, existingItem);
      notifyListeners();
      throw HttpException(msg: "Couldn't delete product!");
    }
    print(response.statusCode);
    existingItem = null;
  }
}

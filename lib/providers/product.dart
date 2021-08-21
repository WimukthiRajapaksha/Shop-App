import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url =
        "https://shop-app-flutter-5ea50-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token";
    final oldFavValue = this.isFavorite;
    this.isFavorite = !this.isFavorite;
    notifyListeners();
    try {
      final response =
          await http.put(Uri.parse(url), body: json.encode(this.isFavorite));
      if (response.statusCode >= 400) {
        this.setFavStatus(oldFavValue);
      }
    } catch (error) {
      this.setFavStatus(oldFavValue);
    }
  }

  void setFavStatus(bool status) {
    this.isFavorite = status;
    notifyListeners();
  }
}

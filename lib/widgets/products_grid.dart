import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorites;

  ProductsGrid(this.showFavorites);

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final items =
        showFavorites ? productProvider.favoriteItems : productProvider.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0),
        itemBuilder: (ctx, index) {
          return ChangeNotifierProvider.value(
              value: items[index], child: ProductItem());
        });
  }
}

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProducts extends StatelessWidget {
  static const routeName = "/user-product";

  const UserProducts({Key? key}) : super(key: key);

  Future<void> _refreshProduct(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProduct.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProduct(context),
                    child: Consumer<ProductProvider>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (ctx, index) {
                            return Column(
                              children: [
                                UserProductItem(
                                  id: productsData.items[index].id,
                                  title: productsData.items[index].title,
                                  imageUrl: productsData.items[index].imageUrl,
                                ),
                                Divider()
                              ],
                            );
                          },
                          itemCount: productsData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

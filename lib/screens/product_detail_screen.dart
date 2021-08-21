import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;

  // ProductDetailScreen(this.title);

  static const routeName = "/product-detail";

  @override
  Widget build(BuildContext context) {
    final itemId = ModalRoute.of(context)?.settings.arguments as String;
    Product product =
        Provider.of<ProductProvider>(context, listen: false).findById(itemId);

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(product.title),
    //   ),
    //   body: SingleChildScrollView(
    //     child: Column(
    //       children: [
    //         Container(
    //           height: 300,
    //           width: double.infinity,
    //           child: Hero(
    //             tag: product.id,
    //             child: Image.network(
    //               product.imageUrl,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //         ),
    //         SizedBox(
    //           height: 10,
    //         ),
    //         Text(
    //           "\$${product.price}",
    //           style: TextStyle(color: Colors.grey, fontSize: 20),
    //         ),
    //         SizedBox(
    //           height: 10,
    //         ),
    //         Container(
    //           child: Text(
    //             product.description,
    //             textAlign: TextAlign.center,
    //           ),
    //           width: double.infinity,
    //           padding: EdgeInsets.symmetric(horizontal: 10),
    //         )
    //       ],
    //     ),
    //   ),
    // );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.title),
              background: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  "\$${product.price}",
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Text(
                    product.description,
                    textAlign: TextAlign.center,
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                Container(
                  height: 1000,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

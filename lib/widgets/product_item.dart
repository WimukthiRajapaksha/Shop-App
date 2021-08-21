import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final Product product;

  // const ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (ctx) => ProductDetailScreen(this.product.title)));
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          // child: Image.network(
          //   product.imageUrl,
          //   fit: BoxFit.cover,
          // ),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage("assets/images/placeholder.jpg"),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.contain,
            ),
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavoriteStatus(
                    authData.authToken!, authData.userId ?? "");
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Added item to cart",
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: "UNDO",
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      })));
            },
            color: Theme.of(context).accentColor,
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

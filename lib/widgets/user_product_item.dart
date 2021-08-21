import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(
      {required this.id, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(this.imageUrl),
      ),
      title: Text(this.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProduct.routeName, arguments: this.id);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<ProductProvider>(context, listen: false)
                      .deleteProduct(this.id);
                } catch (error) {
                  scaffold.showSnackBar(SnackBar(
                    content: Text(
                      "Deleting failed!",
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
              },
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}

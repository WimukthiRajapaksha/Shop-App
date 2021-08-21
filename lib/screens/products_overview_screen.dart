import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showOnlyFav = false;
  var _isInit = true;
  var _isLoadingData = false;

  @override
  void didChangeDependencies() {
    if (this._isInit) {
      setState(() {
        _isLoadingData = true;
      });
      Provider.of<ProductProvider>(context).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoadingData = false;
        });
      });
    }
    this._isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == FilterOptions.Favorites) {
                setState(() {
                  _showOnlyFav = true;
                });
              } else {
                setState(() {
                  _showOnlyFav = false;
                });
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.All,
              )
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, value, child) => Badge(
              child: child!,
              value: value.itemsCount.toString(),
            ),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart)),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: (this._isLoadingData)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFav),
    );
  }
}

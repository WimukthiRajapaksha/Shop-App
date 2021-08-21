import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        // ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: (ctx) => ProductProvider(),
          update: (context, value, previous) {
            previous!.userId = value.userId;
            previous.authToken = value.authToken;
            return previous;
          },
        ),
        // update: (ctx, auth, previousProducts) {
        //       previousProducts.authToken = auth.authToken!, (previousProducts == null) ? [] : previousProducts.items})),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        // ChangeNotifierProvider(create: (ctx) => Orders()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(),
          update: (context, value, previous) {
            previous!.userId = value.userId;
            previous.authToken = value.authToken;
            return previous;
          },
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Shop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato",
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProducts.routeName: (ctx) => UserProducts(),
            EditProduct.routeName: (ctx) => EditProduct(),
          },
        ),
      ),
    );
  }
}

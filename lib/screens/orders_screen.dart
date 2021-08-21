import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

// class OrdersScreen extends StatefulWidget {
//   static const routeName = "/orders";

//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   var _isLoading = false;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   Future.delayed(Duration.zero).then((value) async {
//   //     setState(() {
//   //       this._isLoading = true;
//   //     });
//   //     await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
//   //     setState(() {
//   //       this._isLoading = false;
//   //     });
//   //   });
//   // } -> statefullwidget

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   this._isLoading = true;
//   //   Provider.of<Orders>(context, listen: false)
//   //       .fetchAndSetOrders()
//   //       .then((value) {
//   //     setState(() {
//   //       this._isLoading = false;
//   //     });
//   //   });
//   // } -> statefullwidget

//   @override
//   Widget build(BuildContext context) {
//     // final orders = Provider.of<Orders>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Your Orders"),
//       ),
//       drawer: AppDrawer(),
//       // body: this._isLoading
//       //     ? Center(child: CircularProgressIndicator())
//       //     : ListView.builder(
//       //         itemCount: orders.items.length,
//       //         itemBuilder: (ctx, index) {
//       //           return OrderItem(
//       //             orderItem: orders.items[index],
//       //           );
//       //         },
//       //       ),
//       body: FutureBuilder(
//           future:
//               Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
//           builder: (ctx, dataSnapshot) {
//             if (dataSnapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else {
//               if (dataSnapshot.error != null) {
//                 return Center(child: Text("Error while loading data"));
//               } else {
//                 return Consumer<Orders>(
//                     builder: (ctx, orderData, child) => ListView.builder(
//                           itemCount: orderData.items.length,
//                           itemBuilder: (ctx, index) {
//                             return OrderItem(
//                               orderItem: orderData.items[index],
//                             );
//                           },
//                         ));
//               }
//             }
//           }),
//     );
//   }
// }

// class OrdersScreen extends StatelessWidget {
// static const routeName = "/orders";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Your Orders"),
//       ),
//       drawer: AppDrawer(),
//       body: FutureBuilder(
//         future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
//         builder: (ctx, dataSnapshot) {
//           if (dataSnapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else {
//             if (dataSnapshot.error != null) {
//               return Center(child: Text("Error while loading data"));
//             } else {
//               return Consumer<Orders>(
//                 builder: (ctx, orderData, child) => ListView.builder(
//                   itemCount: orderData.items.length,
//                   itemBuilder: (ctx, index) {
//                     return OrderItem(
//                       orderItem: orderData.items[index],
//                     );
//                   },
//                 ),
//               );
//             }
//           }
//         },
//       ),
//     );
//   }
// }

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _orders;
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    super.initState();
    this._orders = this._obtainOrdersFuture();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: this._orders,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              return Center(child: Text("Error while loading data"));
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.items.length,
                  itemBuilder: (ctx, index) {
                    return OrderItem(
                      orderItem: orderData.items[index],
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}

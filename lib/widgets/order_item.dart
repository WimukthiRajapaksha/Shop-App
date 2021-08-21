import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderItem;

  const OrderItem({Key? key, required this.orderItem}) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 450),
      height: this._expanded
          ? min(widget.orderItem.products.length * 20 + 120, 200)
          : 100,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text("\$${widget.orderItem.amount}"),
              subtitle: Text(DateFormat("dd/MM/yyyy hh:mm")
                  .format(widget.orderItem.dateTime)),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 450),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: (this._expanded)
                  ? min(widget.orderItem.products.length * 20 + 10, 100)
                  : 0,
              child: ListView(
                children: widget.orderItem.products
                    .map((item) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${item.quantity}X \$${item.price}",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            )
                          ],
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

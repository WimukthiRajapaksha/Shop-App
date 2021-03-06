import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  Badge({required this.child, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      (color == null) ? Theme.of(context).accentColor : color),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ))
      ],
    );
  }
}

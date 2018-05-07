import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'converter_route.dart';

class Category extends StatelessWidget {
  Category(this.icon, this.title);

  final IconData icon;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ConverterRoute(
                name: title,
                color: Colors.lightGreenAccent,
                units: <Unit>[
                  Unit(name: "hello", conversion: 5.4)
                ]);
          }));
        },
        child: Container(
          height: 100.0,
          child: Directionality(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DecoratedBox(
                    child: Icon(
                      icon,
                      size: 60.0,
                    ),
                    decoration: BoxDecoration(),
                  ),
                ),
                Center(
                  heightFactor: 1.0,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ],
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}

const Color _darkGreen = Color(0xABCDEF);

class CategoryRoute extends StatefulWidget {
  @override
  State createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: _darkGreen,
          elevation: 0.0,
          title: Center(
            child: Text(
              "Unit Converter",
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Category(Icons.title, "title"),
            Category(Icons.home, "home")
          ],
        ),
      ),
    );
  }
}

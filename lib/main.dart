import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_route.dart';
import 'settings.dart';
import 'unit.dart';
import 'weight.dart';

import 'package:android_intent/android_intent.dart';

void main() {
  runApp(MyApp());
  print("hello");
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "record your weight",
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WeightUnit unit = WeightUnit.Kg;
  List<Weight> histories = <Weight>[];
  var _lock = Object();


  @override
  void initState() {

    
    SharedPreferences.getInstance().then((s) {
      setState(() {
        unit = WeightUnit.of(s.getString(UNIT_KEY) ?? "Kg");
        print("unit is $unit (${unit.name})");
      });
    });

    allWeight().then((histories) {
      setState(() {
        this.histories = histories;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MyRoute((context) {
                return Settings();
              })).then((_) async {
                var s = await SharedPreferences.getInstance();
                setState(() {
                  unit = WeightUnit
                      .of(s.getString(UNIT_KEY) ?? WeightUnit.Kg.name);
                });
              });
            },
            tooltip: "settings",
          )
        ],
        title: Text("Weight History"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => new Dismissible(
              background: Container(
                color: Colors.red,
              ),
              onDismissed: (direction) {
                var w = histories[index].weight;
                histories.removeAt(index);
                updateHistory(histories);

                Scaffold
                    .of(context)
                    .hideCurrentSnackBar(reason: SnackBarClosedReason.remove);

                Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Item removed! (weight:$w)"),
                    ));
              },
              key: ObjectKey(histories[index]),
              child: WeightWidget(histories[index], unit),
            ),
        itemCount: histories.length,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "new weight",
          onPressed: () async {
            bool added = await newWeightDialog(context) ?? false;
            if (added) {
              print("added");
              allWeight().then((histories) {
                setState(() {
                  this.histories = histories;
                });
              });
            } else {
              print("not added");
            }
          }),
    );
  }
}

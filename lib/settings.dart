import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'unit.dart';

class Settings extends StatefulWidget {
  @override
  State createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  WeightUnit unit = WeightUnit.Kg;

  @override
  void initState() {
    SharedPreferences.getInstance().then((s) {
      setState(() {
        unit = WeightUnit.of(s.getString(UNIT_KEY) ?? WeightUnit.Kg.name);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("Unit"),
              DropdownButton(
                value: unit,
                items: <DropdownMenuItem<WeightUnit>>[
                  DropdownMenuItem<WeightUnit>(
                    value: WeightUnit.Kg,
                    child: Text(WeightUnit.Kg.name),
                  ),
                  DropdownMenuItem<WeightUnit>(
                    value: WeightUnit.Pound,
                    child: Text(WeightUnit.Pound.name),
                  ),
                ],
                onChanged: (unit) {
                  setUnit(unit);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  setUnit(WeightUnit unit) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setString(UNIT_KEY, unit.name);
    setState(() {
      this.unit = unit;
    });
  }
}

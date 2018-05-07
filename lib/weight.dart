import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:locking/locking.dart';
import 'package:path_provider/path_provider.dart';

import 'unit.dart';

const _split = "!";
const history = "history";
const valid_digit = "0123456789.";

const Object _lock = Object();

class Weight {
  final double weight;
  DateTime _now;

  int get timeSinceEver => _now.millisecondsSinceEpoch;

  Weight([this.weight = 50.0]) {
    _now = DateTime.now();
  }

  static Weight from(String msg) {
    List<String> res = msg.split(_split);
    assert(res.length == 2);
    double w = double.parse(res[0]);
    DateTime now = DateTime.fromMillisecondsSinceEpoch(int.parse(res[1]));
    Weight weight = Weight(w);
    weight._now = now;
    return weight;
  }

  Weight.copy(Weight weight)
      : this.weight = weight.weight,
        this._now = weight._now;

  String get time {
    DateTime local = _now.toLocal();
    return "${local.year.toString().padLeft(4, '0')}-${local.month.toString()
        .padLeft(2, '0')}-${local.day
        .toString().padLeft(2, '0')} ${local.hour.toString().padLeft(
        2, '0')}:${local
        .minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(
        2, '0')}";
  }

  @override
  String toString() {
    return "$weight$_split${_now.millisecondsSinceEpoch}";
  }
}

class WeightWidget extends StatelessWidget {
  final Weight weight;
  final WeightUnit unit;

  WeightWidget(this.weight, this.unit);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {},
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${WeightUnit.Kg.to(weight.weight, unit).toStringAsFixed(
                          2)} ${unit.name} ",
                      style: TextStyle(color: Colors.black87, fontSize: 24.0),
                    ),
                  ),
                  heightFactor: 1.5,
                ),
                flex: 1,
              ),
              new Container(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    weight.time,
                    style: TextStyle(color: Colors.black26, fontSize: 12.0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

_historyFile() async {
  Directory dir = await getApplicationDocumentsDirectory();
  dir = dir.absolute;
  File h = File("${dir.path}/$history");
  if (!await h.exists()) {
    h.createSync();
  }

  return h;
}

newWeight(Weight w) async {
  await lock(_lock, () async {
    File history = await _historyFile();
    history.writeAsStringSync("${w.toString()}\n",
        mode: FileMode.APPEND, flush: true);
  });
}

Future<List<Weight>> allWeight() async {
  List<String> lines;
  await lock(_lock, () async {
    File history = await _historyFile();
    lines = history.readAsLinesSync();
  });
  return lines.map((s) => Weight.from(s)).toList();
}

removeWeight(int timeSinceEver) async {
  await lock(_lock, () async {
    File history = await _historyFile();
    var histories = history.readAsLinesSync();
    int index = 0;
    while (index < histories.length) {
      try {
        int _timeSinceEver = int.parse(histories[index].split(_split)[1]);
        if (timeSinceEver == _timeSinceEver) {
          histories.removeAt(index);
          break;
        }
      } catch (e) {
        print('$e:$histories');
        break;
      }
      index++;
    }
    var ioSink = history.openWrite();
    for (String w in histories) {
      ioSink.writeln(w);
    }
    await ioSink.flush();
    await ioSink.close();
  });
}

Future updateHistory(List<Weight> history) async {
  var action = () async {
    File historyFile = await _historyFile();

    var file = historyFile.openWrite();
    try {
      for (Weight weight in history) {
        file.writeln(weight.toString());
      }
      await file.flush();
    } finally {
      await file.close();
    }
  };
  await lock(_lock, action);
}

newWeightDialog(BuildContext context) {
  AlertDialog dialog = AlertDialog(
    contentPadding: EdgeInsets.all(4.0),
    titlePadding: EdgeInsets.all(8.0),
    title: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(child: Text("New Weight")),
    ),
    content: WeightDialogContent(),
  );

  return showDialog(context: context, builder: (c) => dialog);
}

class WeightDialogContent extends StatefulWidget {
  @override
  State createState() => _WeightDialogContentState();
}

class _WeightDialogContentState extends State<WeightDialogContent> {
  TextEditingController controller;

  double get weight {
    return double.parse(controller.text ?? 0.0);
  }

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _goBack(bool added) {
    Navigator.of(context).pop(added);
  }

  @override
  Widget build(BuildContext context) {
    var ok = () {
      double w;
      try {
        w = weight;
      } catch (e) {
        print(e);
        _goBack(false);
        return;
      }
      newWeight(Weight(w));
      _goBack(true);
    };

    return Container(
      height: 150.0,
      child: Column(
        children: <Widget>[
          Container(
              child: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration:
                InputDecoration(labelText: "new weight", hintText: "50.0"),
            onChanged: (s) {
              int l = min(s.length, 10);
              StringBuffer buffer = StringBuffer();
              for (int i = 0; i < l; i++) {
                String char = s[i];
                if (valid_digit.contains(char)) {
                  if (char == "." && buffer.toString().contains(".")) {
                    continue;
                  }
                  buffer.write(char);
                }
              }
              l = buffer.length;
              int base = min(controller.selection.baseOffset, l);
              int extend = min(l, controller.selection.extentOffset);

              controller.text = buffer.toString();
              controller.selection =
                  TextSelection(baseOffset: base, extentOffset: extend);
            },
            onSubmitted: (s) {
              ok();
            },
          )),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                  textColor: Colors.lightBlue,
                  color: Colors.white,
                  splashColor: Colors.lightBlueAccent,
                  onPressed: () {
                    _goBack(false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )),
              FlatButton(
                textColor: Colors.white,
                  color: Colors.lightBlueAccent,
                  splashColor: Colors.lightBlue,
                  onPressed: ok,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      "OK",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

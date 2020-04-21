import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

void main() => runApp(SimuAube());

class SimuAube extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
              title: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          )),
          color: Colors.white,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          textTheme: TextTheme(
              title: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          )),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TimeCard start = TimeCard(
    title: "Heure de début d'allumage",
    time: TimeOfDay(hour: 7, minute: 15),
  );
  TimeCard inter = TimeCard(
    title: "Heure de luminosité maximale",
    time: TimeOfDay(hour: 7, minute: 20),
  );
  TimeCard end = TimeCard(
    title: "Heure d'arrêt",
    time: TimeOfDay(hour: 7, minute: 25),
  );

  String message;

  @override
  void initState() {
    super.initState();
    message = "-";
  }

  void _sendTime() {
    DateTime now = DateTime.now();
    String newMessage = "*";
    newMessage += "${now.year},${now.month},${now.day},";
    newMessage += "${now.hour},${now.minute},${now.second},";
    newMessage += "${start.time.hour},${start.time.minute},";
    newMessage += "${inter.time.hour},${inter.time.minute},";
    newMessage += "${end.time.hour},${end.time.minute}";
    setState(() {
      message = newMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simulateur d\'Aube',
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "Connexion Bluetooth",
                              style: Theme.of(context).textTheme.title,
                            ),
                            leading: Icon(
                              Icons.bluetooth,
                              size: 40.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  start,
                  inter,
                  end,
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          OutlineButton(
                            onPressed: _sendTime,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.refresh),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Valider",
                                    style: Theme.of(context)
                                        .textTheme
                                        .button
                                        .copyWith(fontSize: 25.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Text("Message envoyé : $message"),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeCard extends StatefulWidget {
  TimeOfDay time;
  String title;

  TimeCard({this.time, this.title});

  @override
  _TimeCardState createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  void _changeTime() async {
    TimeOfDay newTime =
        await showTimePicker(context: context, initialTime: widget.time);
    if (newTime != null) {
      setState(() {
        widget.time = newTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.title,
              ),
              leading: Icon(
                Icons.timer,
                size: 40.0,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Text(
                    "${widget.time.hour}h ${widget.time.minute}",
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
              ),
            ),
            ButtonBar(
              buttonPadding: EdgeInsets.all(5.0),
              children: <Widget>[
                FlatButton(
                  child: Text("CHANGER"),
                  onPressed: _changeTime,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

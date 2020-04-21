import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'package:link/link.dart';

void main() => runApp(SimuAube());

class SimuAube extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Simulateur d\'Aube',
          ),
          centerTitle: true,
        ),
        body: MainScreen(),
      ),
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
  String item;
  List<BluetoothDevice> _devices = <BluetoothDevice>[];
  int currentDeviceId;
  BluetoothConnection connection;

  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;

  @override
  void initState() {
    super.initState();
    message = "-";
    _refreshDevices();
    currentDeviceId = -1;
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Envoyé avec succès !"),
        ));
      } catch (e) {
        setState(() {});
      }
    }
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
      _sendMessage(message);
    });
  }

  void _refreshDevices() {
    bluetoothSerial
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        _devices = bondedDevices;
      });
    });
  }

  void _connect() {
    if (currentDeviceId == -1) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Sélectionnez un appareil"),
      ));
      return;
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Connexion..."),
    ));
    BluetoothDevice currentDevice = _devices[currentDeviceId];
    BluetoothConnection.toAddress(currentDevice.address).then((_connection) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Connecté à l'appareil !"),
      ));
      connection = _connection;
    }).catchError((error) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text("Erreur de connexion, l'appareil est-il allumé et à portée ?"),
      ));
    });
  }

  List<DropdownMenuItem<int>> _getDevicesDropDownItems() {
    List<DropdownMenuItem<int>> list = [];
    for (int id = 0; id < _devices.length; id++) {
      list.add(DropdownMenuItem<int>(
        value: id,
        child: Text("${_devices[id].name} (${_devices[id].address})"),
      ));
    }
    list.add(DropdownMenuItem<int>(
      value: -1,
      child: Text("Sélectionnez un appareil"),
    ));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: DropdownButton<int>(
                            value: currentDeviceId,
                            isExpanded: true,
                            onChanged: (int newValue) {
                              setState(() {
                                currentDeviceId = newValue;
                              });
                            },
                            items: _getDevicesDropDownItems(),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              OutlineButton(
                                onPressed: _refreshDevices,
                                child: Text('Actualiser'),
                              ),
                              OutlineButton(
                                onPressed: _connect,
                                child: Text('Connecter'),
                              ),
                            ],
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
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            "A propos",
                            style: Theme.of(context).textTheme.title,
                          ),
                          leading: Icon(
                            Icons.info,
                            size: 40.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                  "Cette application a été créée par Timothée "
                                      "Danneels avec Flutter pour contrôler un simulateur"
                                      " d'aube fonctionnant avec une carte Arduino."
                                      "\nUn simulateur d'aube est un réveil fonctionnant"
                                      " à la lumière : l'intensité lumineuse permet de "
                                      "réveiller son utilisateur."
                                      " Ici, l'intensité de la lumière augmente de façon linéaire, depuis l'heure"
                                      " de début d'allumage jusqu'à l'heure d'intensité maximale."
                                      " Ensuite, elle reste constante jusqu'à l'heure d'arrêt.",
                                textAlign: TextAlign.justify,
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Site web : '),
                                  Link(
                                    child: Text('tidann.alwaysdata.net'),
                                    url: 'http://www.google.com',
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text('Code source '),
                                  Link(
                                    child: Text('tidann.alwaysdata.net'),
                                    url: 'http://www.google.com',
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              Text(
                                "tidann dev - 2020",
                                style: Theme.of(context).textTheme.title,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
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

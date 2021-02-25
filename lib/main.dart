import 'package:flutter/material.dart';
import 'package:flutter_application_2/Mapview.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
    routes: {
      '/map': (context) => Mapview(),
    },
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String defaultlocation = 'Welcome';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Current Location'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$defaultlocation',
                style: TextStyle(color: Colors.amber, fontSize: 25.0),
              ),
              FlatButton(
                  color: Colors.amber,
                  onPressed: () {
                    Navigator.pushNamed(context, '/map');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_location),
                      Text('Show In Map'),
                    ],
                  )),
            ],
          )),
    );
  }
}

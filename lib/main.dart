import 'package:flutter/material.dart';
import 'package:webrtc_tutorial/webrtc_controller.dart';
import 'package:webrtc_tutorial/webrtc_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebrtcController _webrtcController = WebrtcController();

  @override
  void initState() {
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
        title: Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  _webrtcController.connect?.call();
                },
                child: Text("Connect"),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {});
            },
            child: Text("Update"),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: WebrtcPlayer(
                    url: 'ws://51.250.98.53:3333/app/stream?transport=tcp',
                    controller: _webrtcController,
                  )),
                ],
              ),
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}

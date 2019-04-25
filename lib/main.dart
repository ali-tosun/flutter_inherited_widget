import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int number;

  void numChangeCallback(int receivedNum) {
    setState(() {
      number = receivedNum;
    });
  }

  @override
  void initState() {
    super.initState();
    number = 0;
  }

  Future<String> myFuture() async {
    var myJsonData =
        await http.get("https://jsonplaceholder.typicode.com/posts/1");
    var jsonMap = jsonDecode(myJsonData.body);
    //debugPrint(jsonMap[0]['userId']);
    return jsonMap['title'];
  }

  @override
  Widget build(BuildContext context) {

      return FutureBuilder(future: myFuture(),builder: (context,snapshat){

        if(snapshat.connectionState == ConnectionState.done){
          return  NameManager(
            name: snapshat.data.toString(),
            child: MaterialApp(
              theme: ThemeData(
                primarySwatch: Colors.red,
              ),
              home: NumManager(
                //home property sini Inherited widget ile sarmalıyoruz,böylece alt sınıflar bu değişkenlere istediği yerden ulaşabilecektir.
                // bir widget ağacında aynı inherited widgeti kullanabiliriz, NumManager.of(context).callback şeklinde erişecek kişi
                // kendisine en yakınındaki NumManager şeklinde tanımlanmış sınıfın değişkenlerine erişir.
                  number: number,
                  callback: numChangeCallback,
                  child: homeScreen()),
            ),
          );
        }else{
          return Center(child: CircularProgressIndicator(),);
        }

      });

  }
}

class homeScreen extends StatefulWidget {
  @override
  _homeScreenState createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  @override
  Widget build(BuildContext context) {
    int _number = NumManager.of(context)
        .number; //NumManager in statik methodu sayesinde number değişkenine erişebiliyoruz.
    //kullanma amacamız widget ağacımız çok büyüdüğünde constructor kullanmadan parametrelere ulaşmak.
    Function(int) _callback = NumManager.of(context).callback;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inherited Callback Pattern'),
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _callback(++_number);
        },
        child: Text('+1'),
      ),
      body: new CenterWidget(),
    );
  }
}

class CenterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("ilk name manager" + NameManager.of(context).name);

    return NameManager(
      name: "Ali Tosun",
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new TextWidget(),
            RaisedButton(
              onPressed: () {
                var myFunction = NumManager.of(context).callback;
                var myNumber = NumManager.of(context).number;
                debugPrint("raised button name manager" +
                    NameManager.of(context).name);

                myFunction(--myNumber);
              },
              child: Text("Decrease"),
            ),
          ],
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    debugPrint("ikinci name manager" + NameManager.of(context).name);

    int inheritedNumber = NumManager.of(context).number;
    String myName = NameManager.of(context).name;

    return Text(
      "${inheritedNumber.toString()} $myName",
      style: TextStyle(
          fontSize: 40.0, color: Colors.red, fontWeight: FontWeight.w900),
    );
  }
}

class NumManager extends InheritedWidget {
  final int number;
  final Widget child;
  final Function(int) callback;
  final Key key;

  NumManager(
      {@required this.number,
      @required this.callback,
      @required this.child,
      this.key})
      : super(key: key);

  @override
  bool updateShouldNotify(NumManager oldWidget) {
    return oldWidget.number == number;
  }

  static NumManager of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(NumManager);
}

class NameManager extends InheritedWidget {
  final String name;
  final Widget child;
  final Key key;

  NameManager({@required this.name, @required this.child, this.key})
      : super(key: key);

  @override
  bool updateShouldNotify(NameManager oldWidget) {
    return oldWidget.name == name;
  }

  static NameManager of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(NameManager);
}

/*
Widget homeScreenBuilder(BuildContext context) {
  int _number = NumManager
      .of(context)
      .number;
  Function(int) _callback = NumManager
      .of(context)
      .callback;
  return Scaffold(
    appBar: AppBar(
      title: Text('Inherited Callback Pattern'),
      elevation: 0.0,
    ),
    floatingActionButton: FloatingActionButton(onPressed: () {
      _callback(++_number);
    },child: Text('+1'),),
    body: Center(
      child: Text(_number.toString(),style: TextStyle(fontSize: 40.0, color: Colors.red, fontWeight: FontWeight.w900),),
    ),
  );
}
*/

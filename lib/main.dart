import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class MyAppState extends ChangeNotifier {
  var temp = 1;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          Text('hi'),
          ButtonRows(buttonValues: ['π', 'e', '(', ')']),
          ButtonRows(buttonValues: ['AC', '^', '√', '÷']),
          ButtonRows(buttonValues: ['7', '8', '9', 'x']),
          ButtonRows(buttonValues: ['3', '5', '6', '-']),
          ButtonRows(buttonValues: ['1', '2', '3', '+']),
          ButtonRows(buttonValues: ['0', '.', '⌫', '=']),
          /*ElevatedButton(
            onPressed: () {},
            child: const Text('hi'),
          )*/
        ],
      ),
    );
  }
}

class ButtonRows extends StatelessWidget {
  const ButtonRows({
    super.key,
    required this.buttonValues,
  });

  final List<String> buttonValues;

  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            print('hi');
          },
          child: Text(buttonValues[0]),
        ),
        ElevatedButton(
          onPressed: () {
            print('hi');
          },
          child: Text(buttonValues[1]),
        ),
        ElevatedButton(
          onPressed: () {
            print('hi');
          },
          child: Text(buttonValues[2]),
        ),
        ElevatedButton(
          onPressed: () {
            print('hi');
          },
          child: Text(buttonValues[3]),
        ),
      ],
    );
  }
}

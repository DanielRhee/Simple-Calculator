import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'evaluate_expression.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppController(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class AppController extends ChangeNotifier {
  List<String> currExpression = [];
  String currExpressionString = '';
  String currRes = '';

  void expressionToString() {
    //Turns expression into a string
    currExpressionString = '';
    for (var i = 0; i < currExpression.length; i++) {
      currExpressionString += currExpression[i];
    }
    //print(currExpressionString);
    notifyListeners();
  }

  void expressionOperation(String newChar, int index) {
    //Function for adding operators to the string
    if (newChar == 'AC') {
      //Clearing
      currExpression = [];
    } else if (newChar == '⌫') {
      //Backspace
      if (currExpression.isNotEmpty) {
        currExpression.removeLast();
      }
    } else {
      //Adding everything else
      if (index != -1) {
        currExpression.insert(index, newChar);
      } else {
        currExpression.add(newChar);
        if (newChar == '√' || newChar == '^') {
          currExpression.add('(');
        }
      }
    }

    expressionToString();
    evaluateExpression();
  }

  void evaluateExpression() {
    List<String> postfixExpression = shuntingYard(currExpression);
    try {
      currRes = evaluatePostfix(postfixExpression).toString();
    } catch (e) {
      print(e);
      currRes = 'NaN';
    }
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppController>();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(appState.currExpressionString),
                Text(appState.currRes),
              ],
            ),
          ),
          //Buttons
          const ButtonRows(buttonValues: ['π', 'e', '(', ')']),
          const ButtonRows(buttonValues: ['AC', '^', '√', '÷']),
          const ButtonRows(buttonValues: ['7', '8', '9', 'x']),
          const ButtonRows(buttonValues: ['4', '5', '6', '-']),
          const ButtonRows(buttonValues: ['1', '2', '3', '+']),
          const ButtonRows(buttonValues: ['0', '.', '⌫', '=']),
        ],
      ),
    );
  }
}

class ButtonRows extends StatefulWidget {
  const ButtonRows({
    super.key,
    required this.buttonValues,
  });

  final List<String> buttonValues;

  @override
  State<ButtonRows> createState() => _ButtonRowsState();
}

class _ButtonRowsState extends State<ButtonRows> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppController>();
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            appState.expressionOperation(widget.buttonValues[0], -1);
          },
          child: Text(widget.buttonValues[0]),
        ),
        ElevatedButton(
          onPressed: () {
            appState.expressionOperation(widget.buttonValues[1], -1);
          },
          child: Text(widget.buttonValues[1]),
        ),
        ElevatedButton(
          onPressed: () {
            appState.expressionOperation(widget.buttonValues[2], -1);
          },
          child: Text(widget.buttonValues[2]),
        ),
        ElevatedButton(
          onPressed: () {
            appState.expressionOperation(widget.buttonValues[3], -1);
          },
          child: Text(widget.buttonValues[3]),
        ),
      ],
    );
  }
}

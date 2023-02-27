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
  //Storing history
  List<List<String>> expressionHistory = [];
  String expressionHistoryString = '';
  String resultHistoryString = '';

  //Active expressions
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
    } else if (newChar == '=') {
      //End expression and move onto the next
      if (expressionHistoryString != '' && resultHistoryString != '') {
        expressionHistoryString += '\n';
        resultHistoryString += '\n';
      }
      expressionHistoryString += currExpressionString;
      resultHistoryString += currRes;
      expressionOperation('AC', -1);
      notifyListeners();
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isKeyboardOpen = false;
  final historyScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppController>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: SingleChildScrollView(
              controller: historyScrollController,
              reverse: true,
              //controller: historyScrollController,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Text(appState.expressionHistoryString),
                    Expanded(child: Container()),
                    SelectableText(appState.resultHistoryString),
                  ],
                ),
              ),
            ), // Historic Expression Data
          ),

          const Divider(
            height: 5,
            color: Colors.black45,
          ),

          //Flexible(fit: FlexFit.loose, child: Container()),

          //Expanded(child: Container()),
          //Keyboard opener
          //Positioned(bottom:child: KeyboardExpansion()),
          Column(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Text(appState.currExpressionString),
                  Expanded(child: Container()),
                  SelectableText(appState.currRes),
                ],
              ),
            ),
            ExpansionPanelList(
                animationDuration: Duration(milliseconds: 300),
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return const ListTile(
                        title: Text('Open Keyboard'),
                      );
                    },
                    body: Column(//ListTile(
                        children: const [
                      ButtonRows(buttonValues: ['π', 'e', '(', ')']),
                      ButtonRows(buttonValues: ['AC', '^', '√', '÷']),
                      ButtonRows(buttonValues: ['7', '8', '9', 'x']),
                      ButtonRows(buttonValues: ['4', '5', '6', '-']),
                      ButtonRows(buttonValues: ['1', '2', '3', '+']),
                      ButtonRows(buttonValues: ['0', '.', '⌫', '=']),
                    ]),
                    isExpanded: isKeyboardOpen,
                    canTapOnHeader: true,
                  ),
                ],
                dividerColor: Colors.grey,
                expansionCallback: ((panelIndex, isExpanded) {
                  isKeyboardOpen = !isKeyboardOpen;
                  setState(() {});
                })),
          ]),

          //Formatting
        ],
      ),
    );
  }

  void scrollBottomHistory() {
    historyScrollController.animateTo(
        historyScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeIn);
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
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              appState.expressionOperation(widget.buttonValues[0], -1);
            },
            child: Text(widget.buttonValues[0]),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              appState.expressionOperation(widget.buttonValues[1], -1);
            },
            child: Text(widget.buttonValues[1]),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              appState.expressionOperation(widget.buttonValues[2], -1);
            },
            child: Text(widget.buttonValues[2]),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              appState.expressionOperation(widget.buttonValues[3], -1);
            },
            child: Text(widget.buttonValues[3]),
          ),
        ),
      ],
    );
  }
}

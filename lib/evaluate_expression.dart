import 'dart:collection';
import 'dart:math';

bool isNumeric(String s) {
  //Determine if a string is numeric
  if (s == null) {
    return false;
  }
  if (s[0] == '+') {
    return false;
  }
  /*if (s == 'π' || s == 'e') {
    return true;
  } */
  return double.tryParse(s) != null;
}

bool isOperator(String s) {
  Set<String> operators = {'√', '^', 'x', '÷', '+', '-'};
  return (operators.contains(s));
}

bool isConstant(String s) {
  if (s == 'π' || s == 'e') {
    return true;
  }
  return false;
}

int hasHigherPrecedence(String operator1, String operator2) {
  //returns 1 if operator 1 > operator 2;
  Set<String> firstOrder = {'(', ')', '√'};
  Set<String> secondOrder = {'^'};
  Set<String> thirdOrder = {'x', '÷'};
  Set<String> fourthOrder = {'+', '-'};

  int operator1Order = 10;
  int operator2Order = 10;
  //Set level
  if (firstOrder.contains(operator1)) {
    operator1Order = 1;
  } else if (secondOrder.contains(operator1)) {
    operator1Order = 2;
  } else if (thirdOrder.contains(operator1)) {
    operator1Order = 3;
  } else if (fourthOrder.contains(operator1)) {
    operator1Order = 4;
  }

  if (firstOrder.contains(operator2)) {
    operator2Order = 1;
  } else if (secondOrder.contains(operator2)) {
    operator2Order = 2;
  } else if (thirdOrder.contains(operator2)) {
    operator2Order = 3;
  } else if (fourthOrder.contains(operator2)) {
    operator2Order = 4;
  }

  if (operator1Order > operator2Order) {
    return -1;
  } else if (operator1Order < operator2Order) {
    return 1;
  }
  return 0;
}

int numberParameters(String operator) {
  final Map<String, int> parameterCount = {
    '√': 1,
    '^': 2,
    'x': 2,
    '÷': 2,
    '+': 2,
    '-': 2,
  };
  if (parameterCount.containsKey(operator)) {
    return parameterCount[operator] as int;
  } else {
    return -1;
  }
}

double getConstantVal(String s) {
  Map<String, double> constantVal = {
    //To 12 sigfigs
    'π': 3.14159265359,
    'e': 2.71828182846,
  };
  if (constantVal.containsKey(s)) {
    return constantVal[s] as double;
  } else {
    throw "Invalid Constant";
  }
}

double evaluateExpression(String operator, List<double> operands) {
  if (operands.length != numberParameters(operator)) {
    throw "Invalid parameters for given operator";
  } else {
    //Brute force it
    if (operator == '√') {
      return sqrt(operands[0]);
    }
    if (operator == '^') {
      return pow(operands[0], operands[1]) as double;
    }
    if (operator == 'x') {
      return operands[0] * operands[1];
    }
    if (operator == '÷') {
      return operands[0] / operands[1];
    }
    if (operator == '+') {
      print("hi???");
      return operands[0] + operands[1];
    }
    if (operator == '-') {
      return operands[0] - operands[1];
    }
  }
  return 0.0;
}

List<String> shuntingYard(
  List<String> inputInfixExpression,
) {
  //Implementation of the shunting yard algorithm to convert input into rpn
  //https://en.wikipedia.org/wiki/Shunting_yard_algorithm#The_algorithm_in_detail

  //Combine numbers together into 1 number
  List<String> infixExpression = [];
  for (var i = 0; i < inputInfixExpression.length; i++) {
    //Make sure not the first item in the list
    if (i != 0) {
      //Add the last item to the current item
      String prevCombine =
          infixExpression[infixExpression.length - 1] + inputInfixExpression[i];

      //If it's numeric
      if (isNumeric(prevCombine)) {
        //Combine together
        //If the number is negative and there isn't an operator before, keep separate because that's a minus sign
        double combinedNum = double.parse(prevCombine);
        if (combinedNum >= 0 ||
            (infixExpression.length - 1 != 0 &&
                isOperator(infixExpression[infixExpression.length - 2])) ||
            infixExpression.length - 1 == 0) {
          //First condition, if it's >0, always fine, if there's an operator, fine, if it's the first thing it's also fine
          infixExpression.removeLast();
          infixExpression.add(prevCombine);
        } else {
          //The number is negative, so reject the combination and just add the num
          infixExpression.add(inputInfixExpression[i]);
        }
      } else {
        //If it's not numeric,
        infixExpression.add(inputInfixExpression[i]);
      }
    } else {
      //Just append if it's 0
      infixExpression.add(inputInfixExpression[0]);
    }
  }

  //Debug print
  String debugInfixExpression = '';
  for (var tempToken in infixExpression) {
    debugInfixExpression += tempToken;
    debugInfixExpression += '|||';
  }
  print(debugInfixExpression);

  //Dart doesn't have stacks so we're using a list lol
  List<String> rpnRes = [];
  List<String> operatorStack = [];
  print("------------------------------------");

  //Loop all the tokens adapted from https://brilliant.org/wiki/shunting-yard-algorithm/
  for (String currToken in infixExpression) {
    if (isNumeric(currToken)) {
      //Direct push to numbers
      rpnRes.add(currToken);
    } else {
      //If left bracket
      if (currToken == '(') {
        operatorStack.add('(');
      }
      //If right bracket:
      else if (currToken == ')') {
        int currOperatorCheck = operatorStack.length - 1;
        //print(operatortack);
        while (operatorStack[currOperatorCheck] != '(') {
          rpnRes.add(operatorStack[currOperatorCheck]);
          currOperatorCheck--;
          operatorStack.removeLast();
        }
        //Remove last bracket
        operatorStack.removeLast();
      }
      //Else it's an operator
      else {
        //While the top operator has greater precedence or the top operator is associattive and they're equal in precedance
        //Who the hell programmed dart's auto formatting
        while (operatorStack.isNotEmpty &&
            (isOperator(operatorStack[operatorStack.length - 1]) &&
                    (hasHigherPrecedence(
                            operatorStack[operatorStack.length - 1],
                            currToken) ==
                        1) ||
                (hasHigherPrecedence(operatorStack[operatorStack.length - 1],
                            currToken) ==
                        0 &&
                    ((operatorStack[operatorStack.length - 1] == '+' &&
                            currToken != 'x') ||
                        operatorStack[operatorStack.length - 1] == 'x')))) {
          rpnRes.add(operatorStack[operatorStack.length - 1]);
          //print("REMOVED " + operatorStack[operatorStack.length - 1]);
          operatorStack.removeLast();
        }
        operatorStack.add(currToken);
      }
    }
  }
  //Add the remainder of operators
  for (var i = operatorStack.length - 1; i >= 0; i--) {
    rpnRes.add(operatorStack[i]);
  }

  //Debug postfix
  String debugRpnExpression = '';
  for (var tempToken in rpnRes) {
    debugRpnExpression += tempToken;
    debugRpnExpression += ' ';
  }
  print("RPN EXPRESSION: " + debugRpnExpression);

  return rpnRes;
}

double evaluatePostfix(List<String> inputRPN) {
  //Adapted from https://math.oxford.emory.edu/site/cs171/postfixExpressions/
  List<double> numberStack = [];

  for (var currToken in inputRPN) {
    print(numberStack);
    //Just add if it's at oken
    if (isNumeric(currToken)) {
      numberStack.add(double.parse(currToken));
    } else if (isConstant(currToken)) {
      try {
        numberStack.add(getConstantVal(currToken));
      } catch (e) {
        print("INVAID CONSTANT");
      }
    } else {
      //If it's not a token, get the number of argument parameters
      int numParameters = numberParameters(currToken);
      if (numberStack.length < numParameters) {
        throw "Invalid NPM Expression";
      } else {
        List<double> operandsReversed = [];
        for (var i = numberStack.length - 1;
            i > numberStack.length - 1 - numParameters;
            i--) {
          operandsReversed.add(numberStack[i]);
        }
        List<double> operands = List.from(operandsReversed.reversed);
        double calcVal = evaluateExpression(currToken, operands);
        for (var i = 0; i < numParameters; i++) {
          numberStack.removeLast();
        }
        numberStack.add(calcVal);
      }
    }
  }
  if (numberStack.length != 1) {
    print(numberStack);
    throw "Invalid NPM expression";
  } else {
    return numberStack[0];
  }
}

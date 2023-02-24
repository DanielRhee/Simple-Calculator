import 'dart:collection';

bool isNumeric(String s) {
  //Determine if a string is numeric
  if (s == null) {
    return false;
  }
  if (s[0] == '+') {
    return false;
  }
  return double.tryParse(s) != null;
}

bool isOperator(String s) {
  Set<String> operators = {'√', '^', 'x', '÷', '+', '-'};
  return (operators.contains(s));
}

int hasHigherPrecedence(String operator1, String operator2) {
  //returns 1 if operator 1 > operator 2;
  Set<String> firstOrder = {'(', ')'};
  Set<String> secondOrder = {'√', '^'};
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
  List<String> operandStack = [];
  print("------------------------------------");

  //Loop all the tokens adapted from https://brilliant.org/wiki/shunting-yard-algorithm/
  for (String currToken in infixExpression) {
    if (isNumeric(currToken)) {
      //Direct push to numbers
      rpnRes.add(currToken);
    } else {
      //If left bracket
      if (currToken == '(') {
        operandStack.add('(');
      }
      //If right bracket:
      else if (currToken == ')') {
        int currOperatorCheck = operandStack.length - 1;
        //print(operandStack);
        while (operandStack[currOperatorCheck] != '(') {
          rpnRes.add(operandStack[currOperatorCheck]);
          currOperatorCheck--;
          operandStack.removeLast();
        }
        //Remove last bracket
        operandStack.removeLast();
      }
      //Else it's an operator
      else {
        //While the top operator has greater precedence or the top operator is associattive and they're equal in precedance
        //Who the hell programmed dart's auto formatting
        while (operandStack.isNotEmpty &&
            (isOperator(operandStack[operandStack.length - 1]) &&
                    (hasHigherPrecedence(
                            operandStack[operandStack.length - 1], currToken) ==
                        1) ||
                (hasHigherPrecedence(
                            operandStack[operandStack.length - 1], currToken) ==
                        0 &&
                    ((operandStack[operandStack.length - 1] == '+' &&
                            currToken != 'x') ||
                        operandStack[operandStack.length - 1] == 'x')))) {
          rpnRes.add(operandStack[operandStack.length - 1]);
          //print("REMOVED " + operandStack[operandStack.length - 1]);
          operandStack.removeLast();
        }
        operandStack.add(currToken);
      }
    }
  }
  //Add the remainder of operators
  for (var i = operandStack.length - 1; i >= 0; i--) {
    rpnRes.add(operandStack[i]);
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

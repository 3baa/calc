import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(BasicCalculator());
}

class BasicCalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '0';
  bool isRadians = false; 
  bool isInverse = false; 
  bool showScientific = false; 

  void _onButtonClick(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        input = '';
        result = '0';
        isRadians = false; 
        isInverse = false;
      } else if (buttonText == 'RAD') {
        isRadians = !isRadians;
      } else if (buttonText == 'INV') {
        isInverse = !isInverse; 
      } else if (buttonText == '=') {
        try {
          result = _evaluateExpression(input);
        } catch (e) {
          result = e.toString();
        }
      } else if (buttonText == 'π') {
        input += pi.toString();
      } else if (buttonText == 'e') {
        input += e.toString();
      } else {
        if (input.length < 18) {
          input += buttonText;
        } else {
         
       result = 
       'بتعجزنى يعنى!';
        }
      }
    });
  }

  String _evaluateExpression(String expression) {
    try {
      final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      return _calculate(exp).toString();
    } catch (e) {
      return 'Error';
    }
  }

  num _calculate(String expression) {
    final List<String> tokens = _tokenize(expression);
    List<num> values = [];
    List<String> operators = [];

    for (var token in tokens) {
      if (num.tryParse(token) != null) {
        values.add(num.parse(token));
      } else if (_isFunction(token)) {
        values.add(_applyFunction(token, values.removeLast()));
      } else {
        while (operators.isNotEmpty && _precedence(token) <= _precedence(operators.last)) {
          final op = operators.removeLast();
          final b = values.removeLast();
          final a = values.removeLast();
          values.add(_applyOperator(op, a, b));
        }
        operators.add(token);
      }
    }

    while (operators.isNotEmpty) {
      final op = operators.removeLast();
      final b = values.removeLast();
      final a = values.removeLast();
      values.add(_applyOperator(op, a, b));
    }

    return values.first;
  }

  List<String> _tokenize(String expression) {
    final regex = RegExp(r'(\d+\.?\d*)|([+\-*/^])|(sin|cos|tan|log|√|arcsin|arccos|arctan)');
    return regex.allMatches(expression).map((m) => m.group(0)!).toList();
  }

  bool _isFunction(String token) {
    return ['sin', 'cos', 'tan', 'log', '√', 'arcsin', 'arccos', 'arctan'].contains(token);
  }

  num _applyFunction(String func, num value) {
    if (!isRadians) value = value * pi / 180; 

    switch (func) {
      case 'sin':
        return isInverse ? asin(value) : sin(value);
      case 'cos':
        return isInverse ? acos(value) : cos(value);
      case 'tan':
        return isInverse ? atan(value) : tan(value);
      case 'log':
        return log(value); 
      case '√':
        return sqrt(value);
      case 'arcsin':
        return asin(value);
      case 'arccos':
        return acos(value);
      case 'arctan':
        return atan(value);
      default:
        throw UnsupportedError('Unsupported function');
    }
  }

  num _applyOperator(String operator, num a, num b) {
    if (operator == '/' && b == 0) {
       {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('بتعمل اى !! هنولع '),
          duration: Duration(seconds: 2),
        ),
      );return double.nan;
      }
     
    }

    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a / b;
      case '^':
        return pow(a, b);
      default:
        throw UnsupportedError('Unsupported operator');
    }
  }

  int _precedence(String operator) {
    if (operator == '+' || operator == '-') return 1;
    if (operator == '*' || operator == '/') return 2;
    if (operator == '^') return 3;
    return 0;
  }

  Widget _buildButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ElevatedButton(
          onPressed: () => _onButtonClick(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(text, style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 247, 244, 244))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 245, 251),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 113, 175, 237),
        title: Text(
          'Scientific Calculator',
          style: TextStyle(color: const Color.fromARGB(255, 62, 69, 80), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomRight,
              child: Text(
                input,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold,color:  const Color.fromARGB(255, 81, 80, 80)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
              alignment: Alignment.bottomRight,
              child: Text(
                result,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 81, 80, 80)),
              ),
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  showScientific ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 25,
                  color: const Color.fromARGB(255, 28, 28, 28),
                ),
                onPressed: () {
                  setState(() {
                    showScientific = !showScientific;
                  });
                },
              ),
            ],
          ),
          Visibility(
            visible: showScientific,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('RAD',const Color.fromARGB(255, 98, 174, 250)),
                    _buildButton('INV',const Color.fromARGB(255, 98, 174, 250)),
                    _buildButton('π',const Color.fromARGB(255, 98, 174, 250)),
                    _buildButton('e',const Color.fromARGB(255, 98, 174, 250)),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('sin', const Color.fromARGB(255, 142, 194, 246)),
                    _buildButton('cos',const Color.fromARGB(255, 142, 194, 246)),
                    _buildButton('tan', const Color.fromARGB(255, 142, 194, 246)),
                    _buildButton('log',const Color.fromARGB(255, 142, 194, 246)),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('√',const Color.fromARGB(255, 142, 194, 246)),
                    _buildButton('^',const Color.fromARGB(255, 142, 194, 246)),
                    _buildButton('arcsin', const Color.fromARGB(255, 142, 194, 246)),
                    _buildButton('arccos', const Color.fromARGB(255, 142, 194, 246)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _buildButton('7', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('8', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('9', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('÷', const Color.fromARGB(255, 113, 175, 237)),
                ],
              ),
              Row(
                children: [
                  _buildButton('4', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('5', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('6', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('×', const Color.fromARGB(255, 113, 175, 237)),
                ],
              ),
              Row(
                children: [
                  _buildButton('1', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('2', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('3', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('-', const Color.fromARGB(255, 113, 175, 237)),
                ],
              ),
              Row(
                children: [
                  _buildButton('0', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('.', const Color.fromARGB(255, 119, 121, 122)),
                  _buildButton('=', const Color.fromARGB(255, 113, 175, 237)),
                  _buildButton('+', const Color.fromARGB(255, 113, 175, 237)),
                ],
              ),
              Row(
                children: [
                  _buildButton('C', const Color.fromARGB(255, 119, 121, 122)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


                






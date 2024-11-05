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
  String ans = '0';
  bool isRadians = false;
  bool isInverse = false;
  bool showScientific = false;
  bool isDarkMode = false;

  void _onButtonClick(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        input = '';
        result = '0';
        ans = '0';
      } else if (buttonText == 'RAD') {
        isRadians = !isRadians;
      } else if (buttonText == 'INV') {
        isInverse = !isInverse;
      } else if (buttonText == 'Sci') {
        showScientific = !showScientific;
      } else if (buttonText == 'Ans') {
        input += ans;
      } else if (buttonText == '=') {
        try {
          result = _evaluateExpression(input);
          ans = result;
        } catch (e) {
          result = 'Error';
        }
      } else if (buttonText == 'π') {
        input += pi.toString();
      } else if (buttonText == 'e') {
        input += e.toString();
      } else {
        if (buttonText == '.' && _hasDecimalInCurrentNumber(input)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('اااى دا كله'), duration: Duration(seconds: 2)),
          );
                   result = 'Error';

        } else if (input.length < 18) {
          input += buttonText;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('بتعجزني يعنى ولا اي؟'), duration: Duration(seconds: 2)),
          );
          result = 'Error';
        }
      }
    });
  }

  bool _hasDecimalInCurrentNumber(String expression) {
    int lastOperatorIndex = expression.lastIndexOf(RegExp(r'[\+\-\*/%()]'));
    String currentNumber = expression.substring(lastOperatorIndex + 1);
    return currentNumber.contains('.');
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
      } else if (token == '(') {
        operators.add(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          final op = operators.removeLast();
          final b = values.removeLast();
          final a = values.removeLast();
          values.add(_applyOperator(op, a, b));
        }
        operators.removeLast();
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
    final regex = RegExp(r'(\d+\.?\d*)|([+\-*/%^()])|(sin|cos|tan|log|√|sin⁻¹|cos⁻¹|tan⁻¹)');
    return regex.allMatches(expression).map((m) => m.group(0)!).toList();
  }

  int _precedence(String operator) {
    if (operator == '+' || operator == '-') return 1;
    if (operator == '*' || operator == '÷' || operator == '%') return 2;
    if (operator == '^') return 3;
    return 0;
  }

  bool _isFunction(String token) {
    return ['sin', 'cos', 'tan', 'log', '√', 'sin⁻¹', 'cos⁻¹', 'tan⁻¹'].contains(token);
  }

  num _applyOperator(String operator, num a, num b) {
    if (operator == '/' && b == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بتعمل ايه !! هنولع'), duration: Duration(seconds: 2)),
      );
      return double.nan;
    }

    switch (operator) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '÷':
        return a / b;
      case '%':
        return a * (b / 100);
      case '^':
        return pow(a, b);
      default:
        throw Exception('error');
    }
  }

  num _applyFunction(String function, num value) {
    if (!isRadians) value *= pi / 180;

    switch (function) {
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
      case 'sin⁻¹':
        return asin(value);
      case 'cos⁻¹':
        return acos(value);
      case 'tan⁻¹':
        return atan(value);
      default:
        throw Exception('error');
    }
  }

  Widget _buildButton(String text, Color color, {double? fontSize}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ElevatedButton(
          onPressed: () => _onButtonClick(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(text, style: TextStyle(fontSize: fontSize ?? 20, color: const Color.fromARGB(255, 60, 159, 252))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : const Color.fromARGB(255, 182, 216, 241),
        title: Text('Scientific Calculator', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => setState(() => isDarkMode = !isDarkMode),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(3),
              alignment: Alignment.bottomRight,
              child: Text(input, style: TextStyle(fontSize: 36, color: isDarkMode ? Colors.white : Colors.black)),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5),
              alignment: Alignment.bottomRight,
              child: Text(result, style: TextStyle(fontSize: 30, color: isDarkMode ? Colors.white : Colors.black)),
            ),
          ),
          Divider(),
          // زر السهم في الأعلى
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_drop_down),
                onPressed: _toggleScientific,
              ),
            ],
          ),
          Row(
            children: [
              _buildButton('(', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton(')', const Color.fromARGB(255, 239, 241, 244)),
               _buildButton('%', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('C', const Color.fromARGB(255, 239, 241, 244)),
            
             
            ],
          ),
         
          Visibility(
            visible: showScientific,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('sin', const Color.fromARGB(255, 239, 241, 244)),
                    _buildButton('cos', const Color.fromARGB(255, 239, 241, 244)),
                    _buildButton('tan', const Color.fromARGB(255, 239, 241, 244)),
                    _buildButton('√', const Color.fromARGB(255, 239, 241, 244)),
                  ],
                ),
                 Row(
            children: [
              _buildButton('RAD', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('INV', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('π', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('e', const Color.fromARGB(255, 239, 241, 244)),
            ],
          ),
                Row(
                  children: [
                    _buildButton('sin⁻¹', const Color.fromARGB(255, 239, 241, 244)),
                    _buildButton('cos⁻¹', const Color.fromARGB(255, 239, 241, 244)),
                    _buildButton('tan⁻¹', const Color.fromARGB(255, 239, 241, 244)),
                    _buildButton('log', const Color.fromARGB(255, 239, 241, 244)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildButton('7', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('8', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('9', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('÷', const Color.fromARGB(255, 239, 241, 244)),
            ],
          ),
          Row(
            children: [
              _buildButton('4', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('5', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('6', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('×', const Color.fromARGB(255, 239, 241, 244)),
            ],
          ),
          Row(
            children: [
              _buildButton('1', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('2', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('3', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('-', const Color.fromARGB(255, 239, 241, 244)),
            ],
          ),
          Row(
            children: [
              _buildButton('0', const Color.fromARGB(255, 239, 241, 244)),
              _buildButton('.',const Color.fromARGB(255, 239, 241, 244)),
            
              _buildButton('+', const Color.fromARGB(255, 239, 241, 244)),
            ],
          ),
          Row(
            children: [
             
              // زر Clear تم استبداله بزر "%"
             
                _buildButton('Ans', const Color.fromARGB(255, 239, 241, 244)),
                 _buildButton('<-', const Color.fromARGB(255, 239, 241, 244)),
                Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton(
                    onPressed: () => _onButtonClick('='), // Smaller equals button
                    style: ElevatedButton.styleFrom(
                      backgroundColor:const Color.fromARGB(255, 239, 241, 244),
                      padding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    child: Text('=', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 60, 159, 252))), // Smaller size
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleScientific() {
    setState(() {
      showScientific = !showScientific;
    });
  }
}


                






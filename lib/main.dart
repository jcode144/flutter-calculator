import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String displayText = '0';

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        expression = '';
        displayText = '0';
      } 
      else if (value == 'x²') {
        try {
          if (expression.isEmpty) return;

          double number = double.parse(expression);
          double result = number * number;

          displayText = '$expression x² = $result';
          expression = result.toString();
        } catch (e) {
          displayText = 'Error';
          expression = '';
        }
      } 
      else if (value == '=') {
        try {
          double result = evaluateExpression(expression);
          displayText = '$expression = $result';
          expression = result.toString();
        } catch (e) {
          displayText = 'Error';
          expression = '';
        }
      } 
      else {
        expression += value;
        displayText = expression;
      }
    });
  }

  double evaluateExpression(String expr) {
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');

    List<String> tokens = tokenize(expr);
    List<String> postfix = infixToPostfix(tokens);
    return evaluatePostfix(postfix);
  }

  List<String> tokenize(String expr) {
    final regex = RegExp(r'(\d+\.?\d*|[+\-*/])');
    return regex.allMatches(expr).map((m) => m.group(0)!).toList();
  }

  int precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  List<String> infixToPostfix(List<String> tokens) {
    List<String> output = [];
    List<String> stack = [];

    for (var token in tokens) {
      if (double.tryParse(token) != null) {
        output.add(token);
      } else {
        while (stack.isNotEmpty &&
            precedence(stack.last) >= precedence(token)) {
          output.add(stack.removeLast());
        }
        stack.add(token);
      }
    }

    while (stack.isNotEmpty) {
      output.add(stack.removeLast());
    }

    return output;
  }

  double evaluatePostfix(List<String> postfix) {
    List<double> stack = [];

    for (var token in postfix) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else {
        double b = stack.removeLast();
        double a = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            if (b == 0) throw Exception('Division by zero');
            stack.add(a / b);
            break;
        }
      }
    }
    return stack.single;
  }

  Widget buildButton(String text,
      {Color bgColor = Colors.grey}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(20),
          ),
          onPressed: () => onButtonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Calculator - Your Name'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(20),
            child: Text(
              displayText,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Divider(color: Colors.white),

          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('÷', bgColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('×', bgColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('-', bgColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    buildButton('0'),
                    buildButton('x²', bgColor: Colors.blue),
                    buildButton('=', bgColor: Colors.green),
                    buildButton('+', bgColor: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    buildButton('C', bgColor: Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

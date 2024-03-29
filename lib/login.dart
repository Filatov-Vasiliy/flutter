import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/register.dart';
import 'homescreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
  
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<Map<String, dynamic>> _data = [];
  String _errorMessage = '';
Future<void> getData() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/user/'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = List<Map<String, dynamic>>.from(jsonData);
      });
    }else if(response.statusCode == 500)
    {
      throw Exception('Internal Server Error');
    }else{
      throw Exception('GET error');
    }
  }
  void _login() {
    String login = _loginController.text;
    String password = _passwordController.text;
      _data.forEach((element) {
        if (element["username"] == login && element["password"] == password) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      setState(() {
        _errorMessage = '';
      });
    }});
      setState(() {
        _errorMessage = 'Incorrect login or pasword';
      });
  }
  @override
  void initState() {
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authorization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(
                labelText: 'Login',
              ),
            ),
            const SizedBox(height: 16.0), 
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.red
                ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Enter'),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.add),
                iconSize: 35.0,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
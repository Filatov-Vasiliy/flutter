import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';
import 'homescreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
  
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _register() async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/user/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': _loginController.text,
      'password': _passwordController.text
    }),
  );
  if (response.statusCode == 201){
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }else if(response.statusCode == 500){
    setState(() {
        _errorMessage = 'Internal Server Error';
      });
  }else{
    setState(() {
        _errorMessage = 'Error';
      });
  }
}
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
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
              onPressed: () {_register();},
              child: const Text('Enter'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/homescreen.dart';
import 'package:http/http.dart' as http;

class PostScreen extends StatefulWidget {
  
  final String title;
  final int user;
  final int id;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  PostScreen({
      required this.title,
      required this.user,
      required this.id,
  });

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String _errorMessage = '';
  Map<String, dynamic> _data = {};


  Future<void> updatePost(int id, String title, int user) async {
  final response = await http.put(
    Uri.parse('http://127.0.0.1:8000/post/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'title': title,
      'user': user,
    }),
  );
  _errorMessage = '';
  if( response.statusCode == 404){
    setState(() {
      _errorMessage = 'Not found';
    });
  }else if (response.statusCode == 500){
    _errorMessage = 'Internal server error';
  }else if (response.statusCode == 400){
    _errorMessage = 'Bad request';
  }else{
    _errorMessage = 'Something broken';
  }

}

  Future<void> getData(int id) async {
    _errorMessage = '';
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/post/$id'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = Map<String, dynamic>.from(jsonData);
      });
    }else if( response.statusCode == 404){
      setState(() {
        setState(() {
          _errorMessage = 'Not found';
            });
      });
    }else if (response.statusCode == 500){
      setState(() {
          _errorMessage = 'Internal server error';
            });
    }else if (response.statusCode == 400){
      setState(() {
          _errorMessage = 'Bad request';
            });
    }else{
      setState(() {
          _errorMessage = 'Something broke';
            });
    }
  }
  Future<String> deletePost(int id) async {
    
    final response = await http.delete(Uri.parse('http://127.0.0.1:8000/post/$id'),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'id': id,

    }));
    if (response.statusCode == 204) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = Map<String, dynamic>.from(jsonData);
      });
      return '';
    }else if( response.statusCode == 404){
      setState(() {
          _errorMessage = 'Not found';
      });
      return 'NotFound';
    }else if (response.statusCode == 500){
      setState(() {
          _errorMessage = 'Internal server error';
            });
            return 'Internal server error';
    }else if (response.statusCode == 400){
      setState(() {
          _errorMessage = 'Bad request';
            });
            return 'Bad request';
    }else{
      setState(() {
          _errorMessage = 'Something broke';
            });
            return 'Something broke';
    }

  }
  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    getData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пост'),
      ),
      body: _data.isNotEmpty
      ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Post text:"),
            const SizedBox(height: 30),
            Expanded(
              child: !isEditable
                  ? Text(_data["title"])
                  : TextFormField(
                      initialValue: _data["title"],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) {
                        updatePost(_data["id"], value, _data["user"]);
                        setState(() {isEditable = false; _data["title"] = value;});
                      }
                  )
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.edit),
                iconSize: 35.0,
                onPressed: () {
                  setState(() {
                        isEditable = true;
                      });
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.delete),
                iconSize: 35.0,
                onPressed: () {
                  String er = deletePost(_data["id"]) as String;
                  if (er == ''){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => const HomeScreen()));
                  }
                },
              ),
            ),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.red
                ),
            ),
          ],
        ),
      )
      : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
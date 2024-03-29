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

  Map<String, dynamic> _data = {};
  Future<void> updatePost(int id, String title, int user) async {
  final response = await http.put(
    Uri.parse('http://127.0.0.1:8000/post/$id/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'title': title,
      'user': user,
    }),
  );
}

  Future<void> getData(int id) async {
    
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/post/$id'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = Map<String, dynamic>.from(jsonData);
      });
    }
  }
  Future<void> deletePost(int id) async {
    
    final response = await http.delete(Uri.parse('http://127.0.0.1:8000/post/$id'),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'id': id,

    }));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = Map<String, dynamic>.from(jsonData);
      });
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
                  deletePost(_data["id"]);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => const HomeScreen()));
                },
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
import 'package:flutter/material.dart';
import 'package:flutter_application/login.dart';
import 'package:flutter_application/postScreen.dart';
import 'package:flutter_application/postcard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _data = [];
  String _errorMessage = '';
  Future<void> getData() async {
    print(1);
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/post/'));
    print(2);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _data = List<Map<String, dynamic>>.from(jsonData);
      });
    }else if (response.statusCode == 500) {
      setState(() {
        _errorMessage='error';
      });
    }
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
        title: const Text('Посты'),
      ),
      body: _data.isNotEmpty
        ? ListView.builder(
          itemCount: _data.length,
          itemBuilder: (context, index) {
            getData();
            final item = _data[index];
            return GestureDetector(
              child: Dismissible(
                key: Key(item['id'].toString()),
                onDismissed: (direction) {
                  setState(() {
                    _data.removeAt(index);
                  });
                },
                background: Container(
                  color: Colors.red,
                  child: const Center(
                    child: Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ),
                child: PostCard(
                  title: item["title"],
                  user: item["user"],
                  id: item["id"],
                ),
              ),
            );
          }, 
      )
    : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

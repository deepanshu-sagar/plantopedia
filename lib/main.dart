import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPT-3 Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Plantopedia'),
    );
  }
}

class Message {
  final String userMessage;
  String botMessage;

  Message({required this.userMessage, this.botMessage = 'Waiting for response...'});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Message> _messages = [];
  String _input = '';

  Future<void> fetchResponse(Message message) async {
    final response = await http.post(
      Uri.parse('https://0e8c-98-124-184-202.ngrok-free.app/execute_command_post'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'message': _input,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        message.botMessage = jsonResponse;
      });
    } else {
      throw Exception('Failed to load response');
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text('Message ${index + 1}'),
                  children: <Widget>[
                    ListTile(
                      title: Text('User: ${_messages[index].userMessage}'),
                    ),
                    ListTile(
                      title: Text('Bot: ${_messages[index].botMessage}'),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _input = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your message',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Message newMessage = Message(userMessage: _input);
            _messages.add(newMessage);
            fetchResponse(newMessage);
            _input = '';
          });
        },
        tooltip: 'Send',
        child: const Icon(Icons.send),
      ),
    );
  }
}

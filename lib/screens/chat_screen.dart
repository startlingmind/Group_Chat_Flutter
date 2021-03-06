import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirebaseFirestore.instance;

  final _auth = FirebaseAuth.instance;
  String messageText;
  var loggedUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').snapshots();

  //   FirebaseFirestore.instance
  //       .collection('messages')
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       print(doc['text']);
  //     });
  //   });
  // }

  //accessing messages via streams
  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // getMessages();
                //sign out the user

                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Group Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshots) {
                  if (!snapshots.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ));
                  } else {
                    final messages = snapshots.data.docs;
                    List<MessageBubble> messageBubbles = [];
                    for (var message in messages) {
                      final messageText = message.data['text'];
                      final messageSender = message.data['sender'];
                      final messageBubble = MessageBubble(
                          sender: messageSender, text: messageText);
                      final messageWidget = messageBubbles.add(messageBubble);
                    }
                    return Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        children: messageBubbles,
                      ),
                    );
                  }
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.

                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;

  const MessageBubble({this.sender, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(sender, style: TextStyle(fontSize: 12.0, color: Colors.black54)),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
            color: Colors.lightBlueAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

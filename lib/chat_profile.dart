import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'home_page.dart';

class ChatProfilePage extends StatefulWidget {
  const ChatProfilePage({Key? key, required this.chatName, required this.chatId, required this.iconUrl})
      : super(key: key);
  final String iconUrl;
  final String chatName;
  final String chatId;

  @override
  State<ChatProfilePage> createState() => _ChatProfilePageState();
}

class _ChatProfilePageState extends State<ChatProfilePage> {
  String oppositeUsername = "";
  String oppositeEmail = "";
  bool isDeleted = false;
  fetchUser() async {
    String currentUserId = Auth().currentUser?.uid ?? '';

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .get();

    if (documentSnapshot.exists) {
      Map<String, dynamic>? data = documentSnapshot.data();
      if (data != null && data.containsKey("members")) {
        List<dynamic> members = data['members'];

        String oppositeUserId = members.firstWhere(
              (memberId) => memberId != currentUserId,
          orElse: () => '',
        );

        if (oppositeUserId.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> oppositeUserSnapshot =
          await FirebaseFirestore.instance
              .collection("user")
              .doc(oppositeUserId)
              .get();

          if (oppositeUserSnapshot.exists) {
            Map<String, dynamic>? oppositeUserData = oppositeUserSnapshot.data();
            if (oppositeUserData != null) {
              setState(() {
                oppositeUsername = oppositeUserData['username'] ?? '';
                oppositeEmail = oppositeUserData['email'] ?? '';
              });
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent,
        title: Text(widget.chatName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.iconUrl==""? "https://www.repol.copl.ulaval.ca/wp-content/uploads/2019/01/default-user-icon.jpg":widget.iconUrl),
              ),
              const SizedBox(height: 20.0),
              Text(
                oppositeUsername,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                oppositeEmail,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50.0),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:  MaterialStatePropertyAll<Color>(Colors.red.shade400),
                  ),
                  onPressed:(){
                    setState(() {
                      isDeleted=true;
                    });
                    Auth().deleteChat(widget.chatId);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete),
                      Text("Delete chat"),
                    ],
                  ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

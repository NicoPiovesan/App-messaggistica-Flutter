import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'chat_page.dart';
import 'package:image_picker/image_picker.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleThemeMode() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }
  File? selectedImage;
  var isValid = false;
  String email = "";
  String username = "";
  final TextEditingController searchText = TextEditingController();
  getUsername(userSnapshot,memberId) async{
      username = userSnapshot.get('username') ?? memberId;
  }
  final TextEditingController emailCtrl = TextEditingController();
  bool found=false;
  int currentIndex=0;
  Future<void> signOut() async{
    await Auth().signOut();
  }
  FirebaseFirestore firestore =  FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          background: Colors.white,
          primary: Colors.black,
        )
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home:Scaffold(
        appBar:currentIndex==0?AppBar(
          elevation: 0,
          actions: [
            IconButton(
                onPressed: (){
                  setState(() {
                   searchEmail(context);
                  });
                },
                icon: Icon(Icons.add)
            ),
 //           IconButton(
 //            onPressed: _toggleThemeMode,
 //             icon:_themeMode==ThemeMode.dark? Icon(Icons.dark_mode):Icon(Icons.light_mode),
 //           ),
          ],
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            title:  const Text("Conversations", style: TextStyle(fontSize: 32,fontWeight:FontWeight.bold)),
        ):AppBar(
          title: const Text("Your Profile",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 28),),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: currentIndex==0?SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                child: StreamBuilder(
                  stream:FirebaseFirestore.instance
                      .collection("chats")
                      .snapshots(),
                  builder:(context,snapshot){
                    if(!snapshot.hasData){
                      return Text("No Chats Available");
                    }else{
                      return ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((doc) {
                          String chatName = "";
                          String iconUrl = "";
                          List<String> members = List<String>.from(doc.get('members'));
                          String memberId = doc.get('members')[0] == Auth().currentUser?.uid
                              ? doc.get('members')[1]
                              : doc.get('members')[0];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection("user").doc(memberId).get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox.shrink();
                              }

                              if (!userSnapshot.hasData) {
                                return SizedBox.shrink();
                              }

                              if (!userSnapshot.data!.exists) {
                                return SizedBox.shrink();
                              }

                              String username = userSnapshot.data!.get('username') ?? memberId;
                              chatName = username;
                              iconUrl = userSnapshot.data!.get('profileIcon')??"";
                              String chatId = doc.id;

                              if (members.contains(Auth().currentUser?.uid)) {
                                return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('chats')
                                      .doc(chatId)
                                      .collection('messages')
                                      .orderBy('time', descending: true)
                                      .limit(1)
                                      .snapshots(),
                                  builder: (context, messageSnapshot) {
                                    if (messageSnapshot.connectionState == ConnectionState.waiting) {
                                      return SizedBox.shrink();
                                    }

                                    if (!messageSnapshot.hasData ||
                                        messageSnapshot.data!.docs.isEmpty) {
                                      return SizedBox.shrink();
                                    }

                                    DocumentSnapshot lastMessage = messageSnapshot.data!.docs[0];
                                    String lastMessageText = lastMessage.get('message');
                                    String lastMessageSender = lastMessage.get('sender');

                                    return Dismissible(
                                      key: Key(chatId),
                                      direction: DismissDirection.endToStart,
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        color: Colors.red,
                                        child:const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onDismissed: (direction) {
                                        deleteChat(chatId);
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatPage(chatName: chatName, chatId: chatId,iconUrl:iconUrl),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey.shade400,
                                                width: 0.15,
                                              ),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius:23,
                                                backgroundImage: NetworkImage(iconUrl==""?"https://www.repol.copl.ulaval.ca/wp-content/uploads/2019/01/default-user-icon.jpg":iconUrl),
                                              ),
                                              SizedBox(width: 15),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    username,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 19,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        lastMessageText,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ):
              ProfileScreen(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.red.shade400),
                    ),
                      onPressed:(){
                        setState(() {
                          openGallery();
                        });
                      },
                      child:Text("Change profile Icon")
                  ) ,
                ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.red,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label:"Chats",

            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",

            )
          ],
          currentIndex: currentIndex,
          onTap: (int index){
            setState(() {
              currentIndex=index;
            });
          },
        ),
      ),
    );
  }

  searchEmail(BuildContext context) {
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Search a contact with his email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration:InputDecoration(
                enabledBorder:const OutlineInputBorder(),
                errorText: emailCtrl.text.isEmpty||!isValid?"Insert a valid email":(!found?"No user found":null)
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Colors.red.shade300),
                ),
                onPressed: (){
                  setState(() async{
                    isValid = EmailValidator.validate(emailCtrl.text);
                    if(isValid){
                      found=await Auth().addChat(emailCtrl.text);
                      emailCtrl.clear();
                    }
                  });
                },
                child: const Text("Create"),
            ),
          ],
        ),
      );
    });
  }

  void openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        uploadImage(pickedFile.path);
      });


    }
  }

  Future<String?> uploadFile(String folderName, String filePath) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString()+'.jpg';
    Reference storageReference = FirebaseStorage.instance.ref().child('$folderName/$fileName');
    File file = File(filePath);

    try {
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Errore durante il caricamento del file: $e');
      return null;
    }
  }

  Future<void> uploadImage(String imagePath) async {
    String? imageUrl = await uploadFile('images', imagePath);
    if (imageUrl != null) {
      await Auth().currentUser?.updatePhotoURL(imageUrl);
      Auth().updateIcon();
    }
  }

  noUserFound(BuildContext context) {
    return AlertDialog(
      title: Text("No user found"),
      content: Text("No user Found"),
    );
  }

  void deleteChat(String chatId) {
    Auth().deleteChat(chatId);
  }

}

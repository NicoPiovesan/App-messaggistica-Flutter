import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'chat_page.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_view.dart';
import 'chat_profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';




class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, required this.chatName, required this.chatId, required this.iconUrl})
      : super(key: key);

  final String chatName;
  final String iconUrl;
  final String chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String imageUrlVar = "";
  late bool showCommands= widget.chatId=="Home"?true:false;
  TextEditingController messageController = TextEditingController();
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  File? selectedImage;
  File? selectedFile;
  double dimmerValue = 0.0;
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setNavigationBarColor(Colors.grey.shade200);
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatProfilePage(
                  chatId: widget.chatId,
                  chatName: widget.chatName,
                  iconUrl: widget.iconUrl
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.iconUrl==""? "https://www.repol.copl.ulaval.ca/wp-content/uploads/2019/01/default-user-icon.jpg":widget.iconUrl),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.chatName,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://i.pinimg.com/736x/8c/98/99/8c98994518b575bfd8c949e91d20548b.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: chatMessages()),
            SafeArea(
              child: Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      !showCommands?GestureDetector(
                        onTap: () {
                          popUpMenu();
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Icon(Icons.attach_file, color: Colors.red[200]),
                          ),
                        ),
                      ):SizedBox(width: 0,),
                      SizedBox(width: 10,),
                      Expanded(
                        child: showCommands ? buildCommandsMenu() : buildTextField(),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      !showCommands?GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.send,
                              color: Colors.red[200],
                            ),
                          ),
                        ),
                      ):SizedBox(width: 0,),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Text('No messages available');
        }

        return ListView(
          reverse: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
            document.data() as Map<String, dynamic>;
            String message = data['message'];
            String sender = data['sender'];
            imageUrlVar = data['image'] ?? "";
            Timestamp? timestamp = data['time'];
            String imageUrlVarCpy = imageUrlVar;
            bool isMe = (sender == Auth().currentUser?.uid);
            DateTime dateTime =
            timestamp != null ? timestamp.toDate() : DateTime.now();
            String timeString = DateFormat('HH:mm').format(dateTime);
            String dateString = DateFormat('dd/MM/yyyy').format(dateTime);
            return message != "" || imageUrlVar != ""
                ? Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Align(
                alignment:
                isMe ? Alignment.topRight : Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateString,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                        isMe ? Colors.red[300] : Colors.grey.shade300,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          imageUrlVar != ""
                              ? GestureDetector(
                            onTap: () {
                              setState(() {
                                imageUrlVar = imageUrlVarCpy;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CustomPhotoView(
                                          imageUrl: imageUrlVar),
                                ),
                              );
                            },
                            child: Image.network(
                              imageUrlVar,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                              : Container(
                            width: 0,
                            height: 0,
                          ),
                          Text(
                            message == "image" ? "" : message,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                              isMe ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            timeString,
                            style: TextStyle(
                              fontSize: 12,
                              color: isMe
                                  ? Colors.grey[200]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(
              width: 0,
              height: 0,
            );
          }).toList(),
        );
      },
    );
  }

  void openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        selectedFile = null;
      });

      // Call the function to upload the image to Firebase Storage
      uploadImage(pickedFile.path);
    } else {
      // No image selected
    }
  }

  void openFilePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
        selectedImage = null;
      });

      // Call the function to upload the file to Firebase Storage
      uploadFile(pickedFile.path);
    } else {
      // No file selected
    }
  }

  Future<String?> uploadFile(String filePath) async {
    String? fileName;
    String? fileExtension;

    try {
      // Get the file name and extension
      fileName = filePath.split('/').last;
      fileExtension = fileName.split('.').last;
    } catch (e) {
      print('Error getting file info: $e');
      return null;
    }

    try {
      Reference storageReference =
      FirebaseStorage.instance.ref().child('files/$fileName');

      UploadTask uploadTask = storageReference.putFile(File(filePath));
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }


  Future<void> uploadImage(String imagePath) async {
    String? imageUrl = await uploadFile(imagePath);
    if (imageUrl != null) {
      imageUrlVar = imageUrl;
    }
  }

  Future<void> sendMessage() async {
    String message = messageController.text.trim();


    if (message.isNotEmpty || imageUrlVar != "" || selectedFile != null) {
      String? fileUrl;

      if (selectedFile != null) {
        fileUrl = await uploadFile(selectedFile!.path);
      }

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'message': message.isNotEmpty ? message : "image",
        'sender': Auth().currentUser?.uid,
        'time': Timestamp.now(),
        'image': imageUrlVar != "" ? imageUrlVar : null,
        'file': fileUrl != null ? {
          'fileName': selectedFile!
              .path
              .split('/')
              .last,
          'fileUrl': fileUrl,
        } : null,
      });
      if(showCommands){
        checkMessage(message);
      }
      messageController.clear();
      setState(() {
        selectedImage = null;
        imageUrlVar = "";
        selectedFile = null;
      });


      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  void popUpMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Gallery'),
                onTap: () {
                  openGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_file),
                title: Text('Files'),
                onTap: () {
                  openFilePicker();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void handleCommand(String command) {
    switch(command){
      case "lightOnLR":
        messageController.text = "Turn on the Light in the living room";
        sendMessage();
        break;
      case "lightOffLR":
        messageController.text = "Turn off the Light in the living room";
        sendMessage();
        break;
      case "lightDimLR":
        showDimmerDialog();
        break;
    }
  }

  Widget buildCommandsMenu() {
    return PopupMenuButton<String>(

      onSelected: (value) {
        handleCommand(value);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'lightOnLR',
          child: Text('Turn on the light in the living room'),
        ),
        const PopupMenuItem<String>(
          value: 'lightOffLR',
          child: Text('Turn off the light in the living room'),
        ),
        const PopupMenuItem<String>(
          value: 'lightDimLR',
          child: Text('Dim the light in the living room'),
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: double.infinity,
        height: 50,
        child: Icon(Icons.keyboard_command_key),
      ),
    );
  }


  buildTextField() {
    return TextFormField(
      controller: messageController,
      decoration: InputDecoration(
        hintText: "Send a message...",
        border: InputBorder.none,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        prefixIcon: selectedImage != null
            ? Image.file(
          selectedImage!,
          width: 30,
          height: 30,
          fit: BoxFit.cover,
        )
            : null,
        suffixIcon: selectedFile != null
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              color: Colors.red[200],
            ),
            Text(
              selectedFile!.path.split('/').last,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        )
            : null,
      ),
    );
  }

  void checkMessage(String message) async {
    String autoMessage="";
    DatabaseReference databaseRef =
    FirebaseDatabase.instance.ref().child('livingRoom/devices/light/');
    switch (message) {
      case "Turn on the Light in the living room":
        await databaseRef.child("enable").set(true);
        autoMessage="The light has been turned on in the living room";
        break;
      case "Turn off the Light in the living room":
        await databaseRef.child("enable").set(false);
        autoMessage="The light has been turned off in the living room";
        break;
      case "Dim the light in the living room":
        showDimmerDialog();
        autoMessage="The light has been dimmed in the living room";
        break;
    }
    await Future.delayed(const Duration(seconds: 1));
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'message': autoMessage,
      'sender': 'Home',
      'time': Timestamp.now(),
    });
  }

  void showDimmerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dim the light'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, state) {
                  return SleekCircularSlider(
                    min: 0,
                    max: 100,
                    initialValue: dimmerValue,
                    appearance: CircularSliderAppearance(
                      animDurationMultiplier: 0.1,
                      customColors: CustomSliderColors(
                        trackColor: Color.fromARGB(255, 200, 200, 200),
                        progressBarColor: Colors.red.shade200,
                      ),
                      customWidths: CustomSliderWidths(progressBarWidth: 10),
                    ),
                    onChange: (double value) {
                      dimmerValue = value;
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                dimmerLight(dimmerValue);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );

      },
    );
  }

  void dimmerLight(double dimmerValue) async{
    if(dimmerValue==0){
      checkMessage("Turn off the Light in the living room");
    }
    DatabaseReference databaseRef =
    FirebaseDatabase.instance.ref().child('livingRoom/devices/light/');
    await databaseRef.child("dimmer").set(dimmerValue);
    messageController.text = 'Dim the light to ${dimmerValue.toInt()}%';
    sendMessage();
    await Future.delayed(const Duration(seconds: 1));
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'message': "Light dimmed to ${dimmerValue.toInt()}%",
      'sender': 'Home',
      'time': Timestamp.now(),
    });
  }


}

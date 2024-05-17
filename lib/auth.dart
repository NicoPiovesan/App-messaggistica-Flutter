import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';


class Auth{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChange => firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email, required String password,}) async{
    await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    Auth().addUserToFirestore();
  }

  Future<void> createUserWithEmailAndPassword({
    required String email, required String password,required String username}) async{
    await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    Auth().currentUser?.updateDisplayName(username);
    Auth().addUserToFirestore();
  }

  Future<void> signOut() async{
    await firebaseAuth.signOut();
  }


  Future<void> addUserToFirestore() async {
    User? user = Auth().currentUser;

    if (user != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        await userRef.set({
          'email': user.email,
          'username': user.displayName,
          'userId' : user.uid,
          'chats' : [],
          'profileIcon':user.photoURL
        });
      }
    }
  }

  Future<void> updateIcon() async {
    User? user = Auth().currentUser;

    if (user != null) {
      DocumentReference userRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        await userRef.update({
          'profileIcon':user.photoURL
        });
      }
    }
  }

  Future<bool> addChat(String email) async {
    var uuid = const Uuid();
    CollectionReference chatCollection = FirebaseFirestore.instance.collection('chats');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDoc = querySnapshot.docs[0];
      String userId = userDoc.id;

      QuerySnapshot existingChatSnapshot = await chatCollection
          .where('members', isEqualTo: [userId, Auth().currentUser?.uid])
          .limit(1)
          .get();

      if (existingChatSnapshot.docs.isNotEmpty) {
        return false;
      }


      DocumentReference chatDoc = await chatCollection.add({
        'members': [userId, FirebaseAuth.instance.currentUser?.uid],
        'chatId': uuid.v4(),
        'lastMessage':"",
      });

      CollectionReference messagesCollection = chatDoc.collection('messages');
      await messagesCollection.add({
        'message': '',
        'sender': '',
        'image':"",
        'file':"",
        'time': FieldValue.serverTimestamp(),
      });

      return true;
    }else{
      return false;
    }
  }

  Future<void> deleteChat(chatId) async {
    await FirebaseFirestore.instance.collection("chats").doc(chatId).delete();
  }


}


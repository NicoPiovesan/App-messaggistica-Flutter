import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messagingapp/auth.dart';

class DatabaseService {

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");

  final CollectionReference chatCollection = FirebaseFirestore.instance.collection("chats");




}
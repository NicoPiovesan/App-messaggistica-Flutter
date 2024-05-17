import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:google_sign_in/google_sign_in.dart';



class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isValid=false;
  bool isLogin = true;

  Future<void> signIn() async{
    try{
      await Auth().signInWithEmailAndPassword(email: email.text, password: password.text);
    }on FirebaseAuthException catch(error){}
  }

  Future<void> createUser() async{
    try{
      await Auth().createUserWithEmailAndPassword(email: email.text, password: password.text, username: username.text);
    }on FirebaseAuthException catch(error){}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Welcome",style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
          children: [
              TextField(
                controller: email,
                decoration: InputDecoration(label:Text("Email"),errorText: email.text.isEmpty||!isValid?"Insert a valid email":null),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(label:Text("Password"),errorText: password.text.isEmpty?"Insert a valid password":null),
              ),
              !isLogin?TextField(
                controller: username,
                decoration: InputDecoration(label:Text("Username"),errorText: username.text.isEmpty?"Insert a valid username":null),
              ):Container(),
              ElevatedButton(
                  onPressed: (){
                    setState(() {
                      isValid = EmailValidator.validate(email.text);
                    });
                    if(isValid){
                      isLogin?signIn():createUser();
                    }
                  },
                  child: Text(isLogin?"Log In":"Sign In")
              ),
              ForgotPasswordButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              }),
              TextButton(
                  onPressed: (){
                    setState(() {
                      isLogin=!isLogin;
                    });
                  },
                  child: Text(isLogin?"Don't have you an account? Sign In":"Have you an account? Log In")
              ),
            ],
          ),
        ),
      ),
    );
  }
}

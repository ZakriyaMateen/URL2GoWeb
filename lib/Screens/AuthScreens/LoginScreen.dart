import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url2goweb/Screens/AuthScreens/SignupScreen.dart';
import 'package:url2goweb/Screens/Dashboard.dart';
import 'package:url2goweb/Utils/transitions.dart';

import '../Dashboard2.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.indigo],
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            constraints: BoxConstraints(maxHeight: 400),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: isLoading?Center(child: Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(color: Colors.green,))):SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   Image.asset('assets/logo.png',width: 80,height:80),
                    SizedBox(height: 20),
                    TyperAnimatedTextKit(
                      totalRepeatCount: 3,
                      speed: Duration(milliseconds: 150),
                      isRepeatingAnimation: false,
                      text: ['Welcome Back!'],
                      textStyle: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (v){
                      return  EmailValidator.validate(v.toString())?null:'Invalid Email';
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        enabledBorder: OutlineInputBorder(

                          borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                            borderRadius: BorderRadius.circular(12)
                        ),
                        filled: true,
                        fillColor: Colors.indigo.withOpacity(0.1),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      validator: (v){
                        return v!.length<6?'Invalid Password':null;
                      },
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',

                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),

                          borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.indigo.withOpacity(0.1),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async{
                        if(formKey.currentState!.validate()){
                          try{
                            setState(() {
                              isLoading = true;
                            });
                            await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString()).then((value) {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard2()));
                            });
                          }
                          catch(e){
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        navigateWithTransition(context, SignUpScreen(), TransitionType.slideBottomToTop);
                      },
                      child: Text(
                        "Don't have an account, Signup?",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
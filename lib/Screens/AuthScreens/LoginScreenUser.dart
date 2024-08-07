import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Screens/AuthScreens/SignupScreen.dart';
import 'package:url2goweb/Screens/Dashboard.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url2goweb/Utils/transitions.dart';

import '../../Properties/fontSizes.dart';
import '../../Properties/fontWeights.dart';
import '../Dashboard2.dart';
import 'ForgotPasswordScreen.dart';
import 'SignUpScreenCorp.dart';

class LoginScreenUser extends StatefulWidget {
  @override
  State<LoginScreenUser> createState() => _LoginScreenUserState();
}

class _LoginScreenUserState extends State<LoginScreenUser> {
  String message = '';
  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailCorpController = TextEditingController();
  TextEditingController passwordCorpController = TextEditingController();
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
            constraints: BoxConstraints(maxHeight: 630),
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
                    SizedBox(height: 10),

                    TextFormField(
                      validator: (v){
                        return  EmailValidator.validate(v.toString())?null:'Invalid Email';
                      },
                      controller: emailCorpController,
                      decoration: InputDecoration(
                        hintText: 'Corporation Email',
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
                      controller: passwordCorpController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Corporation Password',

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
                    SizedBox(height: 8),
                    textCenter(message, Colors.red, w400, size12),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () async{
                        if(formKey.currentState!.validate()){
                          try{
                            setState(() {
                              isLoading = true;
                            });
                            try{
                              await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString());
                              String docId = await getDocIdByCorpEmail(emailCorpController.text.toString());
                              if(docId!='empty'){
                                DocumentSnapshot snap = await FirebaseFirestore.instance.collection('CorporationNames').doc(docId).get();
                                String corporationName = await snap['corporationName'];
                                String corporationPassword = await snap['corporationPassword'];
                                String corporationEmail = await snap['corporationEmail'];

                                if(passwordCorpController.text.toString()==corporationPassword){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard2()));
                                  setState(() {
                                    isLoading = false;
                                  });
                                }

                              }
                              else{
                                try{
                                  await FirebaseAuth.instance.signOut();
                                }
                                catch(e){
                                  print(e.toString);
                                }
                                setState(() {
                                  message = 'Invalid Corporation Credentials';
                                  isLoading = false;
                                });
                              }
                            }


                          //Admin creates corporation email, name password,
                          //user logins

                            catch(e){
                              if(FirebaseAuth.instance.currentUser!=null){
                                await FirebaseAuth.instance.signOut();
                              }
                              setState(() {
                                message = 'Invalid email or password';
                                isLoading = false;
                              });
                              print(e.toString);
                            }
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            navigateWithTransition(context, SignUpScreen(), TransitionType.slideBottomToTop);
                          },
                          child: Text(
                            "New User, Signup?",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(width: 7,),
                        TextButton(
                          onPressed: () {
                            navigateWithTransition(context, SignUpScreenCorp(), TransitionType.slideBottomToTop);
                          },
                          child: Text(
                            "New Corporation?",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: ()async{
                                navigateWithTransition(context, ForgotPasswordScreen(), TransitionType.slideTopToBottom);
                          },
                          child: textRubik('Forgot Password?', selectedCategoryColor, w500, size14),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<String> getDocIdByCorpEmail(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CorporationNames')
        .where('corporationEmail', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return 'empty';
    }
  }
}
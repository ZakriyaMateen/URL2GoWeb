import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Screens/AuthScreens/AdminScreen/UsersRequests.dart';
import 'package:url2goweb/Screens/AuthScreens/EmployeeLogin.dart';
import 'package:url2goweb/Screens/AuthScreens/SignupScreen.dart';
import 'package:url2goweb/Screens/Dashboard.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url2goweb/Utils/transitions.dart';

import '../../Properties/fontSizes.dart';
import '../../Properties/fontWeights.dart';
import '../Dashboard2.dart';
import 'ForgotPasswordScreen.dart';
import 'SignUpScreenCorp.dart';

class CorpLogin extends StatefulWidget {
  @override
  State<CorpLogin> createState() => _CorpLoginState();
}

class _CorpLoginState extends State<CorpLogin> {
  String message = '';
  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailCorpController = TextEditingController();
  TextEditingController passwordCorpController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.indigo],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 400,
                  constraints: BoxConstraints(maxHeight: 500),
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
                      child: CircularProgressIndicator(color: Colors.green,))):
                  SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                  onTap:(){Navigator.pop(context);},
                                  child: Icon(Icons.arrow_back,color: textColor,size: 17,))
                            ],
                          ),
                          Image.asset('assets/logo.png',width: 80,height:80),
                          SizedBox(height: 20),
                          TyperAnimatedTextKit(
                            totalRepeatCount: 3,
                            speed: Duration(milliseconds: 150),
                            isRepeatingAnimation: false,
                            text: ['Corp Login'],
                            textStyle: GoogleFonts.rubik(
                              fontSize: 24,
                              fontWeight: w500,
                              color: purple,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            autofillHints: [AutofillHints.email],
                            validator: (v){
                              return  EmailValidator.validate(v.toString())?null:'Invalid Email';
                            },
                            controller: emailCorpController,
                            decoration: InputDecoration(
                              hintText: 'Corp Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              enabledBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              errorBorder: OutlineInputBorder(

                            borderSide: BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(12)
                               ),
                              filled: true,
                              fillColor: Colors.indigo.withOpacity(0.1),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            autofillHints: [AutofillHints.password],

                            validator: (v){
                              return v!.length<6?'Invalid Password':null;
                            },
                            onFieldSubmitted: (v) async{
                              if(formKey.currentState!.validate()){
                                try{
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try{
                                    // await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString());
                                    String docId = await getDocIdByCorpEmail(emailCorpController.text.toString());
                                    if(docId!='empty'){
                                      try{
                                        FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCorpController.text.toString(), password: passwordCorpController.text.toString()).then((value) async{

                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>UsersRequests(corporationEmail: emailCorpController.text.toString())));
                                        });
                                      }
                                      catch(e){
                                        setState(() {
                                          message = 'Incorrect Password!';
                                          isLoading = false;
                                        });
                                      }

                                    }
                                    else{
                                      try{
                                        setState(() {
                                          message = 'Invalid Corporation Credentials';
                                          isLoading = false;
                                        });
                                        // await FirebaseAuth.instance.signOut();
                                      }
                                      catch(e){
                                        print(e.toString);
                                      }

                                    }
                                  }



                                  catch(e){
                                    if(FirebaseAuth.instance.currentUser!=null){
                                      await FirebaseAuth.instance.signOut();
                                    }
                                    setState(() {
                                      message = 'Invalid name or password';
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
                            controller: passwordCorpController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: 'Corp password',

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
                              errorBorder: OutlineInputBorder(

                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(12)
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
                               TextInput.finishAutofillContext();
                              if(formKey.currentState!.validate()){
                                try{
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try{
                                    String docId = await getDocIdByCorpEmail(emailCorpController.text.toString());
                                    if(docId!='empty'){
                                      try{
                                        FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCorpController.text.toString(), password: passwordCorpController.text.toString()).then((value) async{

                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>UsersRequests(corporationEmail: emailCorpController.text.toString())));
                                        });
                                      }
                                      catch(e){
                                        setState(() {
                                          message = 'Incorrect Password!';
                                          isLoading = false;
                                        });
                                      }
                                    }
                                    else{
                                      try{
                                        setState(() {
                                          message = 'Invalid Corporation Credentials';
                                          isLoading = false;
                                        });
                                      }
                                      catch(e){
                                        print(e.toString);
                                      }

                                    }
                                  }

                                  catch(e){
                                    if(FirebaseAuth.instance.currentUser!=null){
                                      await FirebaseAuth.instance.signOut();
                                    }
                                    setState(() {
                                      message = 'Invalid name or password';
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
                              // TextButton(
                              //   onPressed: () {
                              //     navigateWithTransition(context, SignUpScreen(), TransitionType.slideBottomToTop);
                              //   },
                              //   child: Text(
                              //     "New Employee Signup?",
                              //     style: TextStyle(
                              //       color: Colors.indigo,
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(width: 7,),
                              // TextButton(
                              //   onPressed: () {
                              //     navigateWithTransition(context, SignUpScreenCorp(), TransitionType.slideBottomToTop);
                              //   },
                              //   child: Text(
                              //     "New Corp Signup?",
                              //     style: TextStyle(
                              //       color: Colors.indigo,
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              // ),
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
              ],
            ),
          ],
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
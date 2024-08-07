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
import 'SignUpScreenCorp.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String message = '';
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Icon(Icons.arrow_back,color: purple,size: 22,),
                              )
                            ],
                          ),
                          Image.asset('assets/logo.png',width: 80,height:80),
                          SizedBox(height: 20),
                          TyperAnimatedTextKit(
                            totalRepeatCount: 3,
                            speed: Duration(milliseconds: 150),
                            isRepeatingAnimation: false,
                            text: ['Forgot password'],
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
                            onFieldSubmitted:(v) async{
                              // resetEmail();
                              try{
                                // getDocIdByCorpEmail(emailController.text.toString()).then((uid) {
                                //   if(uid!='empty'){
                                //     getPasswordByCorpEmail(emailController.text.toString()).then((oldPassword) {
                                //       if(oldPassword!='empty'){
                                //         navigateWithTransition(context, ForgotPasswordScreenCorp(uid:uid , email: emailController.text.toString(), oldPassword: oldPassword,), TransitionType.slideRightToLeft);
                                //       }
                                //     });
                                //   }
                                //   else{
                                //     resetEmail();
                                //   }
                                // });
                              resetEmail();
                              }

                              catch(e){
                                setState(() {
                                  message = 'Error Occurred!';
                                });
                              }
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

                          SizedBox(height: 15,),


                          Container(
                            width: 320,
                              child: textCenter(message, textColor, w400, size13),
                          ),
                          SizedBox(height: 15,),

                          ElevatedButton(
                            onPressed: () async{
                              // resetEmail();

                              try{
                                // getDocIdByCorpEmail(emailController.text.toString()).then((uid) {
                                //   if(uid!='empty'){
                                //     getPasswordByCorpEmail(emailController.text.toString()).then((oldPassword) {
                                //       if(oldPassword!='empty'){
                                //         navigateWithTransition(context, ForgotPasswordScreenCorp(uid:uid , email: emailController.text.toString(), oldPassword: oldPassword,), TransitionType.slideRightToLeft);
                                //       }
                                //     });
                                //   }
                                //   else{
                                //     resetEmail();
                                //   }
                                // });
                                resetEmail();
                              }
                              catch(e){
                                setState(() {
                                  message = 'Error Occurred!';
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.indigo,
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 10),

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
  Future<String> getPasswordByCorpEmail(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CorporationNames')
        .where('corporationEmail', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['corporationPassword'];
    } else {
      return 'empty';
    }
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

  void resetEmail()async{
      if(formKey.currentState!.validate()){
        try{
          setState(() {
            isLoading = true;
          });
          await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.toString()).then((value) {
            setState(() {
              message = 'Please check your email to reset your password!';
              isLoading = false;
            });
          });


        }
        catch(e){
          print(e.toString());
          setState(() {
            message = e.toString();
            isLoading = false;
          });
        }

      }
    }
}

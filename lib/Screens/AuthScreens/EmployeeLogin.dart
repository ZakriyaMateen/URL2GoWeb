import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Screens/AuthScreens/SignupScreen.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url2goweb/Utils/transitions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Properties/fontSizes.dart';
import '../../Properties/fontWeights.dart';
import '../Dashboard2.dart';
import 'CorpLogin.dart';
import 'ForgotPasswordScreen.dart';



class EmployeeLogin extends StatefulWidget {
  @override
  State<EmployeeLogin> createState() => _EmployeeLoginState();
}

class _EmployeeLoginState extends State<EmployeeLogin> {
  bool rememberMeCheckBoxVal = false;
  String message = '';
  bool _obscureText = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;



  void saveData(String email, String password, String rememberMe)async{
    try{
      var box = await Hive.openBox('remember_me');
      var remember_me_Box = Hive.box('remember_me');
      await remember_me_Box.put('email', email);
      await remember_me_Box.put('password', password);
      await remember_me_Box.put('rememberMe', rememberMe).then((value) {
        print('remembered you!');
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  void getData()async{
    try{
      var box = await  Hive.box('remember_me');
      String rememberMe = await box.get('rememberMe');

      if(rememberMe=='yes'){
        print('yes we remember!');
        String email = await box.get('email');
        String password = await box.get('password');
        setState(() {
          emailController.text=email;
          passwordController.text=password;
          rememberMeCheckBoxVal = true;
        });
      }
 }
    catch(e){
      print(e.toString());
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

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
              children: [
                Container(
                  width: 400,
                  constraints: BoxConstraints(maxHeight: 565),
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
                            text: ['Employee Login'],
                            textStyle: GoogleFonts.rubik(
                              fontSize: 24,
                              fontWeight: w500,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            autofillHints: [AutofillHints.email],

                            validator: (v){
                              return  EmailValidator.validate(v.toString())?null:'Invalid Email';
                            },
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Employee email',
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
                            autofillHints: [AutofillHints.password],

                            validator: (v){
                              return v!.length<6?'Invalid Password':null;
                            },
                            onFieldSubmitted: (v) async{
                              if(formKey.currentState!.validate()){
                                try{
                                  try{
                                    saveData(emailController.text.toString(), passwordController.text.toString(), rememberMeCheckBoxVal?'yes':'no');
                                  }
                                  catch(e){
                                    print(e.toString);
                                  }
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try{
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString()).then((value) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard2()));
                                    });

                                  }


                                  //Admin creates corporation email, name password,
                                  //user logins

                                  catch(e){
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
                            controller: passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: 'Employee password',

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
                          SizedBox(height: 2),


                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                                    Checkbox(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        checkColor: green,
                                        activeColor: white,
                                        value: rememberMeCheckBoxVal, onChanged: (v){

                                      setState(() {
                                        rememberMeCheckBoxVal = v!;
                                      });
                                    }),
                                SizedBox(
                                  width: 5,
                                ),
                                textRoboto('Remember me', textColor, w500, size13),
                                  ],
                          ),
                          SizedBox(height: 15),

                          ElevatedButton(
                            onPressed: () async{
                              if(formKey.currentState!.validate()){
                                try{

                                  try{
                                    saveData(emailController.text.toString(), passwordController.text.toString(), rememberMeCheckBoxVal?'yes':'no');

                                  }
                                  catch(e){
                                    print(e.toString);
                                  }
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try{
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString()).then((value) {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard2()));
                                    });

                                  }


                                  //Admin creates corporation email, name password,
                                  //user logins

                                  catch(e){
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
                                  "New Employee Signup?",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(width: 7,),
                              TextButton(
                                onPressed: () {
                                  navigateWithTransition(context, CorpLogin(), TransitionType.slideBottomToTop);
                                },
                                child: Text(
                                  "Corp Login?",
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
              ],
            ),
            SizedBox(height: 45,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // InkWell(
                //   onTap: (){},
                //   child: Container(
                //     width:300 ,
                //     height: 45,
                //     decoration: BoxDecoration(
                //       color: green,
                //       borderRadius: BorderRadius.circular(20),
                //         gradient: LinearGradient(
                //           colors: [
                //             green.withOpacity(0.9),
                //             green.withOpacity(0.7),
                //             green.withOpacity(0.5),
                //             green.withOpacity(0.3),
                //
                //           ],
                //           begin: Alignment.topLeft,
                //           end: Alignment.bottomRight
                //         ),
                //       boxShadow: [
                //         BoxShadow(color: purple.withOpacity(0.7),spreadRadius: 1),
                //       ]
                //     ),
                //     alignment: Alignment.center,
                //     child: Center(
                //       child: textRoboto('Free Trial', white, w500, size18),
                //     ),
                //   ),
                // )
                
                OutlinedButton(onPressed: ()async{
                  try{
                    await launchUrl(Uri.parse('https://www.u2go.app/pricing'));

                  }
                  catch(e){
                    print(e.toString());
                  }
                }, child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: textRoboto('Free Trial', white, w500, size18),
                ),
                style: OutlinedButton.styleFrom(minimumSize: Size(300,40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                  backgroundColor: Colors.green
                ),
                )
              
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
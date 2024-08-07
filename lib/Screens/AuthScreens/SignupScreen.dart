import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url2goweb/Properties/fontWeights.dart';
import 'package:url2goweb/Screens/AuthScreens/CorpLogin.dart';
import 'package:url2goweb/Screens/AuthScreens/EmployeeLogin.dart';
import 'package:url2goweb/Screens/AuthScreens/LoginScreenUser.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url2goweb/Utils/transitions.dart';
import '../../Properties/Colors.dart';
import '../../Properties/fontSizes.dart';
import '../Dashboard2.dart';
import 'EmailVerificationScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController emailCorpController = TextEditingController();
  TextEditingController rollController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  Uint8List? bytesFromPicker;
  File? _imageFile;
  final picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  Future<void> _selectAndDisplayImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }
  String _imageUrl='';
  bool isSelected=false;

  Future<bool> _uploadImage() async {
    try {
      if (_imageFile == null) {

        isSelected = false;
        return isSelected;
      }

      String fileName = '${FirebaseAuth.instance.currentUser!.uid}DP';
      Reference ref = _storage.ref().child('images/$fileName');

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFile!.path).readAsBytes();

        await ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/jpeg'), // Specify content type for web
        );

        final imageUrl = await ref.getDownloadURL();

        setState(() {
          _imageUrl = imageUrl;
          isSelected = true;
        });

        return isSelected;
      } else {
        await ref.putFile(_imageFile!);
      }

      // final imageUrl = await ref.getDownloadURL();
      //
      // setState(() {
      //   _imageUrl = imageUrl;
      //   isSelected = true;
      // });
      //
      return isSelected;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  String roll = 'Administration'; // To store the selected item
  String message = '';
  Timer? timer;
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
        child:   isLoading?Center(child: CircularProgressIndicator(color: Colors.green,)):
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // textRoboto('Employee Signup', textColorLight, w600, size40),
            // SizedBox(height: 25,),
            Row(

              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,  children: [
                Container(
                  width: 400,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // Image.asset('assets/logo.png',width: 80,height:80),
                        // SizedBox(height: 20),
                        TyperAnimatedTextKit(
                          totalRepeatCount: 3,
                          speed: Duration(milliseconds: 150),
                          isRepeatingAnimation: false,
                          text: ['Employee Signup'],
                          textStyle: GoogleFonts.rubik(
                            fontSize: 24,
                            fontWeight: w500,
                            color: Colors.indigo,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap:(){Navigator.pop(context);},
                                child: Icon(Icons.arrow_back,color: textColor,size: 17,))
                          ],
                        ),
                        SizedBox(height: 20),

                        GestureDetector(
                          onTap:()async{
                            await _selectAndDisplayImage();

                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              //edit here as well. check if the image is selected. if selected replace this placeholder with the selected image
                              child:
                              _imageFile==null?
                              Image.asset('assets/profileImagePlaceHolder.png'):
                              Image.network(_imageFile!.path)
                            )
                            ,

                          )
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: firstNameController,
                          validator: (v){
                            return v!.length<3?'Invalid Name':null;
                          },                    decoration: InputDecoration(
                            hintText: 'First Name',
                            prefixIcon: Icon(Icons.person),
                            border:  OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder:OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.1),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: lastNameController,
                          validator: (v){
                            return v!.length<3    ?'Invalid Last Name':null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Last Name',
                            prefixIcon: Icon(Icons.person),   border:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                              borderRadius: BorderRadius.circular(12),
                            ), errorBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.1),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: emailCorpController,
                          decoration: InputDecoration(
                            hintText: 'Corp Name',
                            prefixIcon: Icon(Icons.corporate_fare_rounded),
                            border:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                              borderRadius: BorderRadius.circular(12),
                            ), errorBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.1),
                          ),
                          validator: (value) {

                              // return !EmailValidator.validate(value.toString())?'Invalid Corp Email': null;
                            return value!.length<1?'Invalid Corp Name':null;

                          },
                        ),
                        // SizedBox(height: 10),
                        // TextFormField(
                        //   controller: passwordCorpController,
                        //   validator: (v){
                        //     return v!.length<6?'Invalid Password':null;
                        //   },                    obscureText: _obscureText,
                        //   decoration: InputDecoration(
                        //     hintText: 'Corp password',
                        //
                        //     prefixIcon: Icon(Icons.lock),
                        //     border:  OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //     suffixIcon: IconButton(
                        //       icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                        //       onPressed: () {
                        //         setState(() {
                        //           _obscureText = !_obscureText;
                        //         });
                        //       },
                        //     ), errorBorder:OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.red, width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     filled: true,
                        //     fillColor: Colors.indigo.withOpacity(0.1),
                        //   ),
                        // ),
                        SizedBox(height: 10),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Employee email',
                            prefixIcon: Icon(Icons.email),   border:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                              borderRadius: BorderRadius.circular(12),
                            ), errorBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.1),
                          ),
                          validator: (value) {
                            if (!EmailValidator.validate(value!)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          validator: (v){
                            return v!.length<6?'Invalid Password':null;
                          },                    obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Employee password',
                            prefixIcon: Icon(Icons.lock),   border:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ), errorBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.1),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordController,
                          validator: (v){
                            return passwordController.text.toString()!=confirmPasswordController.text.toString()?'Passwords do not match':null;
                          },
                          onFieldSubmitted: (v)async{
                            if(_formKey.currentState!.validate()){
                              try{
                                setState(() {
                                  isLoading=true;
                                });
                                String docId = await getDocIdByCorpEmail(emailCorpController.text.toString());
                                if(docId!='empty'){
                                  DocumentSnapshot snap = await FirebaseFirestore.instance.collection('CorporationNames').doc(docId).get();
                                  String corporationName = await snap['corporationName'];
                                  String corporationPassword = await snap['corporationPassword'];
                                  String corporationEmail = await snap['corporationEmail'];
                                  try{
                                    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString()).then((value) async{
                                      // FirebaseAuth.instance.currentUser?.sendEmailVerification();
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showDialog(context: context, builder: (context){return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        child: Container(
                                          width: 200,
                                          height: 150,
                                          decoration: BoxDecoration(
                                              color: white,
                                              borderRadius: BorderRadius.circular(12)
                                          ),
                                          padding: EdgeInsets.all(5),
                                          child: Center(child: textCenter('Please check your email to verify!',textColor, w500, size13)),
                                        ),);
                                      });

                                      verify(corporationEmail,corporationName);

                                    });
                                  }
                                  catch(e){
                                    setState(() {
                                      isLoading = false;
                                      message = 'Invalid Corp Name';
                                    });
                                  }

                                }
                                else{
                                  setState(() {
                                    isLoading = false;
                                    message = 'Invalid Corporation name';
                                  });
                                }
                              }
                              catch(e){
                                print(e.toString());
                                setState(() {
                                  isLoading=false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik(e.toString(), white, w400, size12)));
                                Fluttertoast.showToast(msg: e.toString());
                              }

                            }
                          },
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Confirm Employee password',
                            prefixIcon: Icon(Icons.lock),   border:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                              borderRadius: BorderRadius.circular(12),
                            ), errorBorder:OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.indigo.withOpacity(0.1),
                          ),

                        ),
                        SizedBox(height: 10),


                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        textRoboto('Choose   ', textColor, w500, size15),
                        DropdownButton<String>(
                          value: roll, // Current selected item
                          icon: Icon(Icons.arrow_drop_down), // Dropdown icon
                          iconSize: 24,
                          elevation: 16,
                          borderRadius: BorderRadius.circular(8),
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              roll = newValue!; // Update selected item
                            });
                          },
                          items: <String>[

                            'Administration',
                            'Customer Service',
                            'Sales & Marketing',
                            'Operations',
                            'Finance',
                            'IT',
                            'HR',
                            'Security',

                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value), // Display the item
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                        SizedBox(height: 7),
                        textRubik(message, Colors.red,w400,size12),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async{
                            if(_formKey.currentState!.validate()){
                              try{
                                setState(() {
                                  isLoading=true;
                                });
                                String docId = await getDocIdByCorpEmail(emailCorpController.text.toString());
                                if(docId!='empty'){
                                  DocumentSnapshot snap = await FirebaseFirestore.instance.collection('CorporationNames').doc(docId).get();
                                  String corporationName = await snap['corporationName'];
                                  String corporationPassword = await snap['corporationPassword'];
                                  String corporationEmail = await snap['corporationEmail'];
                                      try{
                                        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.toString(), password: passwordController.text.toString()).then((value) async{
                                          // FirebaseAuth.instance.currentUser?.sendEmailVerification();
                                          print('signuped');
                                          setState(() {
                                            isLoading = false;
                                          });
                                          showDialog(context: context, builder: (context){return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            child: Container(
                                              width: 200,
                                              height: 150,
                                              decoration: BoxDecoration(
                                                  color: white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.all(5),
                                              child: Center(child: textCenter('Please check your email to verify!',textColor, w500, size13)),
                                            ),);
                                          });

                                          verify(corporationEmail,corporationName);

                                                  // if(FirebaseAuth.instance.currentUser!=null){
                                                  //   await FirebaseAuth.instance.signOut();
                                                  //   await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCorpController.text.toString(), password: corporationPassword);
                                                  //   await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                                  //   setState(() {
                                                  //     isLoading = false;
                                                  //   });
                                                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Verification email sent to admin!', white, w400, size12)));
                                                  //   Navigator.pop(context);
                                                  // }
                                                  // else{
                                                  //   await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCorpController.text.toString(), password: corporationPassword);
                                                  //   await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                                  //   setState(() {
                                                  //     isLoading = false;
                                                  //   });
                                                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Verification email sent to admin!', white, w400, size12)));
                                                  //   Navigator.pop(context);
                                                  // }

                                        });
                                      }
                                      catch(e){
                                        setState(() {
                                          isLoading = false;
                                          message = e.toString().substring(0,30)+' ...';
                                        });
                                      }

                                }
                                else{
                                  setState(() {
                                    isLoading = false;
                                    message = 'Invalid Credentials';
                                  });
                                }
                              }
                              catch(e){
                                print(e.toString());
                                setState(() {
                                  isLoading=false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik(e.toString(), white, w400, size12)));
                              Fluttertoast.showToast(msg: e.toString());
                              }

                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
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
  bool canContinue = false;
  bool isEmailVerified = false;
  Future<void> verify(String corporationEmail,String corporationName)async {
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified(corporationEmail,corporationName));
    deleteUserIfNotVerified();
  }
  void deleteUserIfNotVerified()async{
    try{
      Future.delayed(Duration(seconds: 100),()async{
        try{
          print('50');
          if(!isEmailVerified){
            await FirebaseAuth.instance.currentUser!.delete().then((value) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Timer expired after 100 seconds!"),duration: Duration(seconds: 20),));
              // Navigator.pop(context);
            });

          }
        }
        catch(e){

          print('THis One : '+e.toString());
        }
      });
    }
    catch(e){
      print('that One : '+e.toString());
    }
  }
  checkEmailVerified(String corporationEmail,String corporationName) async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      // TODO: implement your code after email verification


        print('yes inside');
        setState((){
          isLoading=true;
        });
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Email Verified',Colors.green[300]!, w400, size13)));
      try{
        await _uploadImage().then((imageSelected)async {
          await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).set(
              {
                'firstName':firstNameController.text.toString(),
                'lastName':lastNameController.text.toString(),
                'password':passwordController.text.toString(),
                'email':emailController.text.toString(),
                'myFollowings':[],
                'requestList':[],
                'roll':roll,
                'isAccepted':false,
                'corporationName':corporationName,
                'corporationEmail':corporationEmail,
                'uid':FirebaseAuth.instance.currentUser!.uid,
                'imageUrl':imageSelected?_imageUrl:'https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/profileImagePlaceHolder.png?alt=media&token=9d64cc25-ec5e-4360-9bd4-0c0663c2f143'
              }).then((value) async{
            await FirebaseFirestore.instance.collection('AllUsers').doc(FirebaseAuth.instance.currentUser!.uid).set(
                {
                  'corporationName':corporationName,
                  'corporationEmail':corporationEmail,
                }
            ).then((value) {

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeLogin()));
              setState(() {
                isLoading=false;
              });
            });
            // await FirebaseFirestore.instance.collection(roll).doc(roll).collection(collectionPath)
          });
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(SnackBar(content: Text("Email Successfully Verified")));
          timer?.cancel();
        });
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Unknown error Occurred!',Colors.green[300]!, w400, size13)));
        setState(() {
          isLoading=false;

        });
      }

        // ScaffoldMessenger.of(context)
        //     .showSnackBar(SnackBar(content: Text("Image Uploaded : "+imageSelected.toString())));


      }



      // Navigator.pop(context);


  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }


  Future<String> getDocIdByCorpEmail(String name) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CorporationNames')
        .where('corporationName', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return 'empty';
    }
  }





}

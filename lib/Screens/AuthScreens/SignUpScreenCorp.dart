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
import '../../Properties/Colors.dart';
import '../../Properties/fontSizes.dart';
import '../Dashboard2.dart';
import 'LoginScreen.dart';

class SignUpScreenCorp extends StatefulWidget {
  @override
  _SignUpScreenCorpState createState() => _SignUpScreenCorpState();
}

class _SignUpScreenCorpState extends State<SignUpScreenCorp> {

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController corpNameController = TextEditingController();
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
    try{
      if (_imageFile == null) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Please select an image first.'),
        //   ),
        // );
        isSelected=false;
        return isSelected;
      }
      // print(_imageFile!.path);
      // print("outside");
      final fileName = _imageFile!.path.split('/').last;
      // print(fileName);
      final ref = _storage.ref().child(DateTime.now().millisecondsSinceEpoch.toString()); // Use a unique identifier for the file name
      // print(ref);
      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFile!.path).readAsBytes();
        // print(imageData);
        UploadTask uploadTask = ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/png'),
        );
        // print('uploadtask');
        TaskSnapshot snapshot = await uploadTask;
        // print("snapshot");
        String downloadUrl = await snapshot.ref.getDownloadURL();
        // await ref.putData(await _imageFile!.readAsBytes());
        final imageUrl = await ref.getDownloadURL();
        // print(imageUrl);


        setState(() {
          _imageUrl=imageUrl;
          isSelected=true;

        });

        return isSelected;
      } else {
        // Mobile platforms
        await ref.putFile(_imageFile!);
      }
      // print('uploaded storage');

      final imageUrl = await ref.getDownloadURL();
      // print(imageUrl);


      setState(() {
        _imageUrl=imageUrl;
      });
      setState(() {
        isSelected=true;
      });
      return isSelected;
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }
  String roll = 'Administration'; // To store the selected item
  String message = '';
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
            // textRoboto('Corp Signup', textColorLight, w600, size40),
            // SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
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
                        Image.asset('assets/logo.png',width: 80,height:80),
                        SizedBox(height: 20),
                        TyperAnimatedTextKit(
                          totalRepeatCount: 3,
                          speed: Duration(milliseconds: 150),
                          isRepeatingAnimation: false,
                          text: ['Corp Signup'],
                          textStyle: GoogleFonts.rubik(
                            fontSize: 24,
                            fontWeight: w500,
                            color: Colors.indigo,
                          ),
                        ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     GestureDetector(
                        //         onTap:(){Navigator.pop(context);},
                        //         child: Icon(Icons.arrow_back,color: textColor,size: 17,))
                        //   ],
                        // ),
                        // GestureDetector(
                        //     onTap:()async{
                        //       await _selectAndDisplayImage();
                        //
                        //     },
                        //     child: Container(
                        //       width: 80,
                        //       height: 80,
                        //       decoration: BoxDecoration(
                        //           shape: BoxShape.circle
                        //       ),
                        //       child: ClipRRect(
                        //           borderRadius: BorderRadius.circular(200),
                        //           //edit here as well. check if the image is selected. if selected replace this placeholder with the selected image
                        //           child:
                        //           _imageFile==null?
                        //           Image.asset('assets/profileImagePlaceHolder.png'):
                        //           Image.network(_imageFile!.path)
                        //       )
                        //       ,
                        //
                        //     )
                        // ),
                        SizedBox(height: 10),
                        // TextFormField(
                        //   controller: firstNameController,
                        //   validator: (v){
                        //     return v!.length<4?'Invalid Name':null;
                        //   },                    decoration: InputDecoration(
                        //   hintText: 'First Name',
                        //   prefixIcon: Icon(Icons.person),
                        //   border:  OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   focusedBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   enabledBorder: OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   errorBorder:OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.red, width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   filled: true,
                        //   fillColor: Colors.indigo.withOpacity(0.1),
                        // ),
                        // ),
                        // SizedBox(height: 10),
                        // TextFormField(
                        //   controller: lastNameController,
                        //   validator: (v){
                        //     return v!.length<4?'Invalid Last Name':null;
                        //   },
                        //   decoration: InputDecoration(
                        //     hintText: 'Last Name',
                        //     prefixIcon: Icon(Icons.person),   border:  OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ), errorBorder:OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.red, width: 1.5),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
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
                          controller: corpNameController,
                          validator: (v){
                            return v!.length<1?'Invalid Corporation Name':null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Corp name',
                            prefixIcon: Icon(Icons.corporate_fare),   border:  OutlineInputBorder(
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
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Corp email',
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
                            hintText: 'Corp password',
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
                          obscureText: _obscureText,
                          onFieldSubmitted: (v) async{
                            if(_formKey.currentState!.validate()){

                              try{
                                setState(() {
                                  isLoading=true;
                                });
                                CollectionReference corpRef = await FirebaseFirestore.instance.collection('CorporationNames');

                                bool alreadyExists = await doesCorpNameExist(corpNameController.text.toString());
                                bool emailAlreadyExists = await doesCorpEmailExist(emailController.text.toString());

                                if(!alreadyExists){
                                  if(!emailAlreadyExists){
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
                                          child: Center(child: textCenter('Please check you email to verify!',textColor, w500, size13)),
                                        ),);
                                      });

                                      verify();

                                    });

                                  }
                                  else{
                                    setState(() {
                                      isLoading = false;
                                      message = 'Corporation Email Already Exists';
                                    });
                                  }
                                }
                                else{
                                  setState(() {
                                    isLoading = false;
                                    message = 'Corporation Name Already Exists';
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
                          decoration: InputDecoration(
                            hintText: 'Confirm Corp password',
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
                        // TextFormField(
                        //   controller: rollController,
                        //   validator: (v){
                        //     return v!.length<2?'Invalid Roll':null;
                        //   },                    decoration: InputDecoration(
                        //     hintText: 'Roll',
                        //     prefixIcon: Icon(Icons.people),   border:  OutlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ), errorBorder:OutlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.red, width: 1.5),
                        //   borderRadius: BorderRadius.circular(12),
                        // ),
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.indigo.withOpacity(0.6), width: 1.5),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     filled: true,
                        //     fillColor: Colors.indigo.withOpacity(0.1),
                        //   ),
                        // ),

                        // DropdownButton<String>(
                        //   value: roll, // Current selected item
                        //   icon: Icon(Icons.arrow_drop_down), // Dropdown icon
                        //   iconSize: 24,
                        //   elevation: 16,
                        //   borderRadius: BorderRadius.circular(8),
                        //   style: TextStyle(color: Colors.black),
                        //   underline: Container(
                        //     height: 2,
                        //     color: Colors.deepPurpleAccent,
                        //   ),
                        //   onChanged: (String? newValue) {
                        //     setState(() {
                        //       roll = newValue!; // Update selected item
                        //     });
                        //   },
                        //   items: <String>[
                        //
                        //     'Administration',
                        //     'Customer Service',
                        //     'Sales & Marketing',
                        //     'Operations',
                        //     'Finance',
                        //     'IT',
                        //     'HR',
                        //     'Security',
                        //
                        //   ].map<DropdownMenuItem<String>>((String value) {
                        //     return DropdownMenuItem<String>(
                        //       value: value,
                        //       child: Text(value), // Display the item
                        //     );
                        //   }).toList(),
                        // ),
                        message!=''?     SizedBox(height: 3):Container(),
                        message!=''?    textRubik(message, Colors.red,w400, size10):Container(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async{
                            if(_formKey.currentState!.validate()){

                              try{
                                setState(() {
                                  isLoading=true;
                                });

                                      bool alreadyExists = await doesCorpNameExist(corpNameController.text.toString());
                                      bool emailAlreadyExists = await doesCorpEmailExist(emailController.text.toString());

                                      if(!alreadyExists){
                                        if(!emailAlreadyExists){
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
                                                child: Center(child: textCenter('Please check you email to verify!',textColor, w500, size13)),
                                              ),);
                                            });

                                            verify();

                                          });

                                        }
                                        else{
                                          setState(() {
                                            isLoading = false;
                                            message = 'Corporation Email Already Exists';
                                          });
                                        }
                                      }
                                      else{
                                        setState(() {
                                          isLoading = false;
                                          message = 'Corporation Name Already Exists';
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
  Future<void> verify()async {
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    deleteUserIfNotVerified();
  }
  void deleteUserIfNotVerified()async{
    try{
      Future.delayed(Duration(seconds: 100),()async{
        try{
          print('50');
          if(!isEmailVerified){
           await FirebaseAuth.instance.signOut();
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
  Timer? timer;
  checkEmailVerified() async {
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
      DocumentReference ref = await FirebaseFirestore.instance.collection('CorporationNames').add(
          {
            'corporationName':corpNameController.text.toString(),
            'corporationEmail':emailController.text.toString(),
            'corporationPassword':passwordController.text.toString(),
          });
      await ref.update({'docId':ref.id}).then((value) async{
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textLeft('Corporation Created Successfully!, Please signup as a normal Employee to enter!', Colors.green[200]!, w400, size12)));

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CorpLogin()));
        setState(() {
          isLoading=false;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Email Verified',Colors.green[300]!, w400, size13)));
      bool imageSelected=await _uploadImage();

      //
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text("Email Successfully Verified")));
      timer?.cancel();
    }



    // Navigator.pop(context);


  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  Future<bool> doesCorpNameExist(String name) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CorporationNames')
        .where('corporationName', isEqualTo: name)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
  Future<bool> doesCorpEmailExist(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CorporationNames')
        .where('corporationEmail', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

}

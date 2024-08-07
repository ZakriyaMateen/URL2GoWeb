
import 'dart:async';
import 'dart:async';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Screens/AuthScreens/AdminScreen/UsersRequests.dart';
import 'package:url2goweb/Screens/AuthScreens/CorpLogin.dart';
import 'package:url2goweb/Screens/AuthScreens/LoginScreen.dart';
import 'package:url2goweb/Screens/AuthScreens/LoginScreenUser.dart';
import 'package:url2goweb/Screens/Dashboard2.dart';
import 'package:url2goweb/Utils/text.dart';

import '../AuthScreens/EmployeeLogin.dart';


class AnimatedSplashScreen extends StatefulWidget {
  const   AnimatedSplashScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen> with SingleTickerProviderStateMixin{

  late AnimationController _controller;
  @override
  void initState() {
    screenTransition();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _controller.forward();
    super.initState();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getUid_IfAvailable (){
    try{
      if(FirebaseAuth.instance.currentUser!=null){
        return FirebaseAuth.instance.currentUser!.uid;
      }
      return 'loggedOff';
    }
    catch(e){
      print(e.toString());
      return 'loggedOff';
    }
  }

  // Future<void> screenTransition()async{
  //   String uid = '';
  //    uid = getUid_IfAvailable();
  //
  //   bool persist = false;
  //    if((uid == 'loggedOff')||(uid == '')){
  //      persist = false;
  //    }
  //    else{
  //      persist = true;
  //    }
  //   if (ModalRoute.of(context)!.settings.name != '/corp') {
  //     // If so, delay the navigation
  //     Future.delayed(Duration(milliseconds: 2400), ()async {
  //       // Check if the current route is still '/corp' after the delay
  //         // Navigate only if the route is still '/corp'
  //         if(persist){
  //           print('yes');
  //           try{
  //             String isAdmin = await getDocIdByCorpEmail(FirebaseAuth.instance.currentUser!.email!);
  //
  //             if(isAdmin == 'empty'){
  //               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard2()));
  //             }
  //             else{
  //               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>UsersRequests(corporationEmail: FirebaseAuth.instance.currentUser!.email!)));
  //             }
  //           }
  //           catch(e){
  //             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard2()));
  //           }
  //         }
  //         else {
  //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeLogin()));
  //         }
  //
  //     });
  //   }
  //
  //
  // }
  // Future<void> choose()async{
  //   try{
  //     String rememberMe = await getRememberMeKey();
  //     if(rememberMe == 'null'){
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmployeeLogin()));
  //     }
  //     else{
  //       await screenTransition();
  //     }
  //   }
  //   catch(e){
  //     print(e.toString);
  //   }
  // }
  Future<String> getRememberMeKey()async{
    try{
      final ref = await SharedPreferences.getInstance();
      String? key = await ref.getString('rememberMe');
      if(key!=null){
        return key;
      }
      else{
        return 'null';
      }
    }
    catch(e){
      return 'null';
    }
  }
  Future<void> screenTransition() async {


    String url = window.location.href;
    if (url.contains('corp')){
      print('contains & returning' );
      return;
    }

    String uid = '';
    uid = getUid_IfAvailable();

    bool persist = (uid != 'loggedOff' && uid != '');

     Timer(Duration(milliseconds: 2400),()async{

      if (url.contains('corp')==false) {
        print('does not contain');

        if (persist) {
          try {
            String isAdmin = await getDocIdByCorpEmail(FirebaseAuth.instance.currentUser!.email!);
            if (isAdmin == 'empty') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard2()));

            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UsersRequests(corporationEmail: FirebaseAuth.instance.currentUser!.email!)));
            }
          } catch (e) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard2()));
            }
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmployeeLogin()));
        }
      }
    });

    // Check again if the route still does not contain '/corp' after delay
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
  @override
  Widget build(BuildContext context) {

    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          Align(alignment: Alignment.center,
              child: Padding(
                padding:  EdgeInsets.only(top: 105),
                child: Image.asset('assets/splashScreenLogo.png',width: 280,),
              )
          ),
          Align(
            alignment: Alignment.center,
            child: Container(width:130,
              height: 130,
              margin: EdgeInsets.only(bottom: 110),
              alignment: Alignment.center,
              child: Center(
                child:   RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
                  child:  Image.asset('assets/logo.png',height: 130,width: 130,),
                ),
              ),
            ),
          ),

          // SizedBox(height: 17,),
          // textRoboto('Url2Go',Colors.black87, FontWeight.bold,23)
        ],
      ),
    );
  }
}


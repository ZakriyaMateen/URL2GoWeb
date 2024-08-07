import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Screens/AuthScreens/EmployeeLogin.dart';

import '../../../Properties/fontSizes.dart';
import '../../../Properties/fontWeights.dart';
import '../../../Utils/text.dart';
import '../CorpLogin.dart';


class UsersRequests extends StatefulWidget {
  final String corporationEmail;
  const UsersRequests({Key? key, required this.corporationEmail}) : super(key: key);

  @override
  State<UsersRequests> createState() => _UsersRequestsState();
}

class _UsersRequestsState extends State<UsersRequests> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {

    double w=MediaQuery.of(context).size.width;
    double h=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: purple.withOpacity(0.3),
      body: isLoading? Center(child: CircularProgressIndicator(color: green,),):Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple, Colors.indigo],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textRoboto('User Requests', white, w600, size22),
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: lightGrey, size: 20),
                      onSelected: (value) async {

                        if (value == 'logout') {
                          // Perform logout action here
                          try {
                            await FirebaseAuth.instance.signOut().then((value) {
                              Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => EmployeeLogin()));
                            });
                          } catch (e) {
                            print(e.toString());
                          }
                        }
                        else if(value == 'changePassword'){
                          resetPassword();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.exit_to_app, color: Colors.black),
                                SizedBox(width: 8),
                                textRoboto('Logout', textColor, w500, size13),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'changePassword',
                            child: Row(
                              children: [
                                Icon(Icons.lock_open_outlined, color: Colors.black),
                                SizedBox(width: 8),
                                textRoboto('Change Password', textColor, w500, size13),
                              ],
                            ),
                          ),
                          // You can add more items if needed
                        ];
                      },
                    ),
                  ],
                ),
                SizedBox(height: 15,),
                Container(
                  width: w*0.4,
                  height: h*0.8,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child:
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection(widget.corporationEmail).doc(widget.corporationEmail).collection('Users').snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                          child: textRoboto('No Requests', textColor, w400, size13),
                                        );
                                      } else {
                                        final docs = snapshot.data!.docs;
                                        return docs.length==0?Center(child: textRoboto('No Requests!', textColor, w500, size20),): ListView.builder(itemBuilder: (context,index){
                                          final data = docs[index].data();
                                          return Container(
                                            width: w*0.4-30,
                                            height: 60,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: 12),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    textRoboto(data['firstName']+' '+data['lastName'], textColor, w500, size15),
                                                    textRoboto(data['email'], textColor, w400, size13),
                                                  ],
                                                ),
                                                 Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () async {
                                                          try {
                                                            await FirebaseFirestore.instance.collection(widget.corporationEmail).doc(widget.corporationEmail).collection('Users').doc(data['uid']).update(
                                                                {'isAccepted': !(data['isAccepted'] ?? false)});
                                                          } catch(e) {
                                                            print(e.toString());
                                                          }
                                                        },
                                                        child: textRoboto((data['isAccepted'] ?? false) == true ? 'Remove' : 'Accept',(data['isAccepted'] ?? false) == true ? textColor:green, w500, size12)
                                                    )


                                                    // TextButton(onPressed: (){}, child: textRoboto('Cancel', textColor, w500, size12)),
                                                  ],
                                                )
                                              ],
                                            ),
                                          );
                                        },itemCount: docs.length,);
                                      }
                                    })
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
  void resetPassword()async{
    try{
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!).then((value) {
        setState(() {
          isLoading = false;
        });
        showDialog(context: context, builder: (context){return
          Center(
            child: Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.all(5),
                child: Center(child: textCenter('Please check you email to change password!',textColor, w500, size13)),
              ),),
          );
        });

      });


    }
    catch(e){
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }

  }

}

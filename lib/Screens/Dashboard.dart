import 'dart:io';
// import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Properties/fontWeights.dart';
import 'package:url2goweb/Screens/Messenger.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url2goweb/Utils/transitions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MetaDataFetch/MetaData.dart';
import '../Properties/fontSizes.dart';
import '../Providers/CategoryProvider.dart';
import '../Providers/DateProvider.dart';
import '../Providers/recentLinksTabProvider.dart';
import '../Utils/CalendarWidget.dart';
import '../Utils/PdfPrint.dart';
import 'AuthScreens/LoginScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String roll = '';
  String profileImageUrl = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  bool isLoading = true;

  Future<void> getUserDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      String _roll = await snapshot['roll'];
      String _firstName = await snapshot['firstName'];
      String _lastName = await snapshot['lastName'];
      String _profileImage = await snapshot['imageUrl'];
      String _email = await snapshot['email'];
      if (_roll.isNotEmpty &&
          _firstName.isNotEmpty &&
          _lastName.isNotEmpty &&
          _profileImage.isNotEmpty &&
          _email.isNotEmpty) {
        setState(() {
          firstName = _firstName;
          lastName = _lastName;
          profileImageUrl = _profileImage;
          email = _email;
          roll = _roll;
        });
      }
      print(profileImageUrl);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Please reload');
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  double sliderVal = 0.2;
  String messageSearchText = '';
  TextEditingController searchFieldController = TextEditingController();
  TextEditingController messagesSearchController = TextEditingController();
  TextEditingController sublistController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: w,
                    height: 8,
                    color: purple,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 18, right: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 8),
                        appBar(w, "$firstName $lastName", roll,
                            profileImageUrl),
                        SizedBox(
                          height: 38,
                        ),
                        linkLogRow(w),
                        SizedBox(
                          height: 20,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              rootCategories(w, h),
                              SizedBox(
                                width: w * 0.005,
                              ),
                              categoryRow(w, h),
                              SizedBox(
                                width: w * 0.02,
                              ),
                              recentLinksContainer(w, h),
                              SizedBox(
                                width: w * 0.04,
                              ),
                              dailyLinksContainer(w, h),
                              SizedBox(
                                width: w * 0.04,
                              ),
                              // messagesContainer(w, h),
                              messagesContainerAllPeople(w, h),
                              SizedBox(
                                width: w * 0.11,
                              ),

                              //here
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget messagesContainerAllPeople(double w, double h) {
    // String chatReceiverProfileImage = '';
    // String chatReceiverUsername = '';
    // String chatReceiverRoll = '';
    // String chatDocId = '';
    // String chatReceiverUid = '';
    // String isRequestMessage = '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [textRubik('Messages', textColor, w500, size28)],
        ),
        SizedBox(
          height: 15,
        ),
        Stack(
          children: [
            Container(
                width: 330,
                height: h * 0.74,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                          child: textRoboto('Error loading messages', textColor,
                              w400, size16),
                        );
                      } else {
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            // final data = messagesDocs[index].data();
                            final data = docs[index].data();

                            return InkWell(
                              onTap: () async {
                                try {} catch (e) {
                                  print(e.toString());
                                  Fluttertoast.showToast(
                                      msg: 'Cannot contact right now!');
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                width: 330,
                                height: 70,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 14),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      data['imageUrl'],
                                                      fit: BoxFit.cover,
                                                    )),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  textRoboto(
                                                      "${capitalizeFirstLetter(data[
                                                              'firstName'])} ${capitalizeFirstLetter(
                                                              data['lastName'])}",
                                                      textColor,
                                                      w500,
                                                      size16),
                                                  SizedBox(
                                                    height: 1.5,
                                                  ),
                                                  textRoboto(data['roll'],
                                                      textColor, w400, size14)
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Divider(
                                      color: pageBackgroundColor,
                                      thickness: 1,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: docs.length,
                          physics: ClampingScrollPhysics(),
                        );
                      }
                    })),
            Positioned(
                bottom: 0,
                child: Container(
                  width: 330,
                  height: 70,
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    width: 310,
                    height: 40,
                    decoration: BoxDecoration(
                        color: offWhite,
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: TextFormField(
                            onChanged: (v) {
                              setState(() {
                                messageSearchText = v;
                              });
                            },
                            controller: searchFieldController,
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: textColor,
                                  letterSpacing: .5,
                                  fontWeight: w400,
                                  fontSize: size14),
                            ),
                            cursorColor: textColor,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search message or link',
                              hintStyle: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    color: textColorLight,
                                    letterSpacing: .5,
                                    fontWeight: w400,
                                    fontSize: size14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }

  Widget messagesContainer(double w, double h) {
    String chatReceiverProfileImage = '';
    String chatReceiverUsername = '';
    String chatReceiverRoll = '';
    String chatDocId = '';
    String chatReceiverUid = '';
    String isRequestMessage = '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [textRubik('Messages', textColor, w500, size28)],
        ),
        const SizedBox(
          height: 15,
        ),
        Stack(
          children: [
            Container(
                width: 330,
                height: h * 0.74,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('Chats')
                        .where('senderUid',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, receiverSnapshot) {
                      if (receiverSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (receiverSnapshot.hasError) {
                        print(receiverSnapshot.error);
                        return Center(
                          child: textRoboto('Error loading messages', textColor,
                              w400, size16),
                        );
                      } else {
                        // final messagesDocs = snapshot.data!.docs;

                        return StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('Chats')
                                // .where('senderUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                .where('receiverUid',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context, senderSnapshot) {
                              if (senderSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (senderSnapshot.hasError) {
                                return Center(
                                  child: textRoboto('Error loading messages',
                                      textColor, w400, size16),
                                );
                              } else {
                                // final messagesDocs = snapshot.data!.docs;
                                final messagesDocs = [
                                  ...receiverSnapshot.data!.docs,
                                  ...senderSnapshot.data!.docs
                                ];
                                final filteredMessages =
                                    messagesDocs.where((data) {
                                  String senderName = "${capitalizeFirstLetter(
                                          data['firstNameSender'])} " +
                                      data['lastNameSender'];
                                  String receiverName = "${capitalizeFirstLetter(
                                          data['firstNameReceiver'])} " +
                                      data['lastNameReceiver'];
                                  String roll = data['receiverUid'] ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? data['rollSender']
                                      : data['rollReceiver'].toString();

                                  return senderName.toLowerCase().contains(
                                          messageSearchText.toLowerCase()) ||
                                      receiverName.toLowerCase().contains(
                                          messageSearchText.toLowerCase()) ||
                                      roll.toLowerCase().contains(
                                          messageSearchText.toLowerCase());
                                }).toList();

                                return filteredMessages.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No matching messages found.',
                                          style: TextStyle(
                                              color: textColor,
                                              fontSize: size16),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemBuilder: (context, index) {
                                          // final data = messagesDocs[index].data();
                                          final data =
                                              filteredMessages[index].data();

                                          return InkWell(
                                            onTap: () async {
                                              try {
                                                //user_1=>user_2

                                                chatReceiverProfileImage = data[
                                                            'receiverUid'] ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid
                                                    ? await data[
                                                        'profileImageSender']
                                                    : await data[
                                                        'profileImageReceiver'];
                                                chatReceiverUsername = data[
                                                            'receiverUid'] ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid
                                                    ? "${capitalizeFirstLetter(data[
                                                            'firstNameSender'])} " +
                                                        data['lastNameSender']
                                                    : "${capitalizeFirstLetter(data[
                                                            'firstNameReceiver'])} " +
                                                        data[
                                                            'lastNameReceiver'];

                                                chatReceiverRoll =
                                                    await data['rollReceiver'];

                                                chatDocId = await data['docId'];
                                                chatReceiverUid =
                                                    await data['receiverUid'];
                                                isRequestMessage = data[
                                                        'isRequestMessage']
                                                    .toString();

                                                navigateWithTransition(
                                                    context,
                                                    Messenger(
                                                        globalChatReceiverProfileImage:
                                                            chatReceiverProfileImage,
                                                        globalchatReceiverUsername:
                                                            chatReceiverUsername,
                                                        globalchatReceiverRoll:
                                                            chatReceiverRoll,
                                                        globalchatDocId:
                                                            chatDocId,
                                                        globalchatReceiverUid:
                                                            chatReceiverUid,
                                                        globalisRequestMessage:
                                                            isRequestMessage
                                                                .toString(),
                                                    followEachother: false,),
                                                    TransitionType.fade);
                                              } catch (e) {
                                                print(e.toString());
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Cannot contact right now!');
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: 10),
                                              width: 330,
                                              height: 70,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 14),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 40,
                                                              height: 40,
                                                              child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: Image
                                                                      .network(
                                                                    data['receiverUid'] ==
                                                                            FirebaseAuth
                                                                                .instance.currentUser!.uid
                                                                        ? data[
                                                                            'profileImageSender']
                                                                        : data[
                                                                            'profileImageReceiver'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                textRoboto(
                                                                    data['receiverUid'] ==
                                                                            FirebaseAuth
                                                                                .instance.currentUser!.uid
                                                                        ? "${capitalizeFirstLetter(data['firstNameSender'])} " +
                                                                            data[
                                                                                'lastNameSender']
                                                                        : "${capitalizeFirstLetter(data['firstNameReceiver'])} " +
                                                                            data['lastNameReceiver'],
                                                                    // chatReceiverUid,
                                                                    textColor,
                                                                    w500,
                                                                    size16),
                                                                SizedBox(
                                                                  height: 1.5,
                                                                ),
                                                                textRoboto(
                                                                    data['receiverUid'] ==
                                                                            FirebaseAuth
                                                                                .instance.currentUser!.uid
                                                                        ? data[
                                                                            'rollSender']
                                                                        : data['rollReceiver']
                                                                            .toString(),
                                                                    textColor,
                                                                    w400,
                                                                    size14)
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        // Container(
                                                        //     width: 20,
                                                        //   height: 20,
                                                        //   decoration: BoxDecoration(
                                                        //     color: yellow,
                                                        //     shape: BoxShape.circle
                                                        //   ),
                                                        //   child: Center(
                                                        //     child: textRoboto(messagesList[index]['unreadMessages'], darkGrey, w400,size10),
                                                        //   ),
                                                        // )
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 7,
                                                  ),
                                                  Divider(
                                                    color: pageBackgroundColor,
                                                    thickness: 1,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: filteredMessages.length,
                                        physics: ClampingScrollPhysics(),
                                      );
                              }
                            });
                      }
                    })),
            Positioned(
                child: Container(
                  width: 330,
                  height: 70,
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    width: 310,
                    height: 40,
                    decoration: BoxDecoration(
                        color: offWhite,
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: TextFormField(
                            onChanged: (v) {
                              setState(() {
                                messageSearchText = v;
                              });
                            },
                            controller: searchFieldController,
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: textColor,
                                  letterSpacing: .5,
                                  fontWeight: w400,
                                  fontSize: size14),
                            ),
                            cursorColor: textColor,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search message or link',
                              hintStyle: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                    color: textColorLight,
                                    letterSpacing: .5,
                                    fontWeight: w400,
                                    fontSize: size14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: 0)
          ],
        ),
      ],
    );
  }

  // Initialize with the current date

  Widget dailyLinksContainer(double w, double h) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Stack(
      children: [
        Container(
          width: 330,
          height: h * 0.8,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: categoryProvider.title.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          textRubik('Daily Links', textColor, w500, size18)
                        ],
                      ),
                      CalendarWidget(),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                          ),
                          textRubik('Link List', textColor, w500, size18),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: 326,
                        height: 35,
                        decoration: BoxDecoration(
                            color: pageBackgroundColor,
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: teal, width: 2)),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                textRubik('SHARE', textColor, w400, size10)
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: darkYellow, width: 2)),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                textRubik('DELETE', textColor, w400, size10)
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: teal, width: 2)),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                textRubik('PRINT', textColor, w400, size10)
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: blue, width: 2)),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                textRubik(
                                    'COMPLETED', lightPurple, w400, size10)
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //HERE I NEED TO GET AND DISPLAY THE DATE
                      Consumer<DateProvider>(
                        builder: (context, dateProvider, _) {
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                width: 330,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Checkbox(
                                          value: false,
                                          activeColor: Colors.green,
                                          onChanged: (v) {},
                                        ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                width: 260,
                                                child: textLink(
                                                    "Europe stocks close higher as marketsmarketsmarketsmarkets",
                                                    textColor,
                                                    w500,
                                                    size14)),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                textRubik('29 Jul 2019',
                                                    textColor, w400, size10),
                                                textRubik(' / ', textColor,
                                                    w400, size10),
                                                textRubik('03:23PM', textColor,
                                                    w400, size10),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    DottedLine(
                                      lineThickness: 1,
                                      lineLength: 240,
                                      dashColor: textColor,
                                      dashGapLength: 2,
                                      dashLength: 4,
                                    ),
                                  ],
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 20,
                          );
                        },
                      )
                    ],
                  ),
                )
              : Center(
                  child: textRubik(
                      'Please select a category!', textColor, w400, size13),
                ),
        ),
        Positioned(
            bottom: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: 310,
              height: 40,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: selectedCategoryColor.withOpacity(0.4),
                  spreadRadius: 1,
                  blurRadius: 1,
                )
              ], color: btnBgColor, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [textRubik("+ Add new URL", white, w400, size14)],
                ),
              ),
            ))
      ],
    );
  }

  bool isLoading2 = false;

  Widget recentLinksContainer(double w, double h) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final fKey = GlobalKey<FormState>();
    TextEditingController addRecentLinkController = TextEditingController();
    return Stack(
      children: [
        Container(
          width: 330,
          height: h * 0.8,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: categoryProvider.title.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            textRubik('Recent links', textColor, w500, size18),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 296,
                          height: 40,
                          margin: EdgeInsets.only(left: 2, right: 2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: sharePrintDeleteOptionBackgroundColor,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Consumer<RecentLinksTabProvider>(
                                builder:
                                    (context, recentLinksTabProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      recentLinksTabProvider
                                          .setSelectedIndex(0);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 3),
                                      constraints: BoxConstraints(
                                          maxHeight: 20, minWidth: 40),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          recentLinksTabProvider.allUnreadNew[0]
                                              ? BoxShadow(
                                                  color:
                                                      darkBlue.withOpacity(0.1),
                                                  blurRadius: 1,
                                                  spreadRadius: 1,
                                                )
                                              : BoxShadow(color: Colors.white),
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: recentLinksTabProvider
                                                .allUnreadNew[0]
                                            ? white
                                            : sharePrintDeleteOptionBackgroundColor,
                                      ),
                                      child: Center(
                                        child: textRubik(
                                            'All',
                                            selectedCategoryColor,
                                            w400,
                                            size12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Consumer<RecentLinksTabProvider>(
                                builder:
                                    (context, recentLinksTabProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      recentLinksTabProvider
                                          .setSelectedIndex(1);
                                    },
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: 20, minWidth: 40),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 3),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          recentLinksTabProvider.allUnreadNew[1]
                                              ? BoxShadow(
                                                  color:
                                                      darkBlue.withOpacity(0.1),
                                                  blurRadius: 1,
                                                  spreadRadius: 1,
                                                )
                                              : BoxShadow(color: Colors.white)
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: recentLinksTabProvider
                                                .allUnreadNew[1]
                                            ? white
                                            : sharePrintDeleteOptionBackgroundColor,
                                      ),
                                      child: Center(
                                        child: textRubik(
                                            'Unread',
                                            selectedCategoryColor,
                                            w400,
                                            size12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Consumer<RecentLinksTabProvider>(
                                builder:
                                    (context, recentLinksTabProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      recentLinksTabProvider
                                          .setSelectedIndex(2);
                                    },
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: 20, minWidth: 40),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 3),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          recentLinksTabProvider.allUnreadNew[2]
                                              ? BoxShadow(
                                                  color:
                                                      darkBlue.withOpacity(0.1),
                                                  blurRadius: 1,
                                                  spreadRadius: 1,
                                                )
                                              : BoxShadow(color: Colors.white)
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                        color: recentLinksTabProvider
                                                .allUnreadNew[2]
                                            ? white
                                            : sharePrintDeleteOptionBackgroundColor,
                                      ),
                                      child: Center(
                                        child: textRubik(
                                            'New',
                                            selectedCategoryColor,
                                            w400,
                                            size12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 3,
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 330,
                            height: h * 0.65,
                            margin: EdgeInsets.only(top: 10),
                            child:

//continue from here

                                Consumer<RecentLinksTabProvider>(builder:
                                    (context, recentLinksTabProvider, _) {
                              return StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('Categories')
                                      .doc(categoryProvider.title)
                                      .collection('RecentLinks')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: textRoboto('Select a Category',
                                            textColor, w400, size13),
                                      );
                                    } else {
                                      List docs = snapshot.data!.docs;

// Function to parse date and time strings into DateTime

                                      if (recentLinksTabProvider
                                          .allUnreadNew[0]) {
                                        // print('0');
                                        // docs = docs;
                                      } else if (recentLinksTabProvider
                                          .allUnreadNew[1]) {
                                        print('1');
                                        docs = docs
                                            .where((doc) => !(doc['readBy']
                                                    as List<dynamic>)
                                                .cast<String>()
                                                .contains(FirebaseAuth
                                                    .instance.currentUser!.uid))
                                            .toList();
                                      } else if (recentLinksTabProvider
                                          .allUnreadNew[2]) {
                                        // Filter docs for today and yesterday
                                        DateTime now = DateTime.now();
                                        DateTime today = DateTime(
                                            now.year, now.month, now.day);
                                        DateTime yesterday =
                                            today.subtract(Duration(days: 1));

                                        docs = docs.where((doc) {
                                          DateTime dateTime = parseDateTime(
                                              doc['date'], doc['time']);
                                          return dateTime.isAfter(yesterday) &&
                                              dateTime.isBefore(
                                                  today.add(Duration(days: 1)));
                                        }).toList();

                                        // Sort the filtered docs based on parsed date and time in descending order
                                        docs.sort((a, b) {
                                          DateTime dateTimeA = parseDateTime(
                                              a['date'], a['time']);
                                          DateTime dateTimeB = parseDateTime(
                                              b['date'], b['time']);
                                          return dateTimeB.compareTo(dateTimeA);
                                        });
                                      }

                                      return ListView.builder(
                                        itemBuilder: (context, index) {
                                          // final data = docs[index].data();
                                          final data = docs[index].data();

                                          return Container(
                                            width: w,
                                            height: 110,
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10),
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    textRubik(
                                                        data['date'],
                                                        textColor,
                                                        w400,
                                                        size10),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    //next line is constant
                                                    textRubik('/', textColor,
                                                        w400, size10),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    textRubik(
                                                        data!['time'],
                                                        textColor,
                                                        w400,
                                                        size10),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 250,
                                                      child: GestureDetector(
                                                          onTap: () async {
                                                            _launchUrl(
                                                                data['url']);
                                                            try {
                                                              DocumentSnapshot snap = await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Categories')
                                                                  .doc(categoryProvider
                                                                      .title)
                                                                  .collection(
                                                                      'RecentLinks')
                                                                  .doc(data[
                                                                      'docId'])
                                                                  .get();
                                                              List<dynamic>
                                                                  readBy = snap[
                                                                      'readBy'];
                                                              print(readBy);
                                                              readBy.add(
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid);
                                                              DocumentReference ref = await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Categories')
                                                                  .doc(categoryProvider
                                                                      .title)
                                                                  .collection(
                                                                      'RecentLinks')
                                                                  .doc(data[
                                                                      'docId']);
                                                              await ref.update({
                                                                'readBy': FieldValue
                                                                    .arrayUnion(
                                                                        readBy)
                                                              });
                                                            } catch (e) {
                                                              print(e);
                                                            }
                                                          },
                                                          child: textLink(
                                                              (data['url'] ==
                                                                          data[
                                                                              'metaData']) ||
                                                                      data['metaData'] ==
                                                                          'Empty'
                                                                  ? data['url']
                                                                  : data[
                                                                      'metaData'],
                                                              textColor,
                                                              w500,
                                                              size16)),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        try {
                                                          if (data[
                                                                  'senderUid'] !=
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) {
                                                            print(data[
                                                                'senderUid']);
                                                            DocumentSnapshot docSnap = await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Chats')
                                                                .doc(data["senderId"]
                                                                        .toString() +
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid
                                                                        .toString())
                                                                .get();
                                                            if (docSnap
                                                                    .exists ==
                                                                false) {
                                                              DocumentSnapshot docSnap2 = await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Chats')
                                                                  .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid +
                                                                      data["senderId"]
                                                                          .toString())
                                                                  .get();
                                                              if (docSnap2
                                                                      .exists ==
                                                                  false) {
                                                                String uid = data[
                                                                    'senderUid'];
                                                                //sender who posted a link ||^
                                                                DocumentSnapshot
                                                                    user =
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Users')
                                                                        .doc(
                                                                            uid)
                                                                        .get();

                                                                if (user
                                                                    .exists) {
                                                                  String
                                                                      _profileImage =
                                                                      await user[
                                                                          'imageUrl'];
                                                                  String
                                                                      _firstName =
                                                                      await user[
                                                                          'firstName'];
                                                                  String _roll =
                                                                      await user[
                                                                          'roll'];
                                                                  String
                                                                      _lastName =
                                                                      await user[
                                                                          'lastName'];

                                                                  bool
                                                                      checkIfFirstMessage =
                                                                      false;
                                                                  //we check if it is the first message by checking if the document exists or not

                                                                  DocumentReference ref = await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'Chats')
                                                                      .doc(FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid +
                                                                          uid.toString());

                                                                  // MyUid + RecieverUid

                                                                  DocumentSnapshot
                                                                      snapshot =
                                                                      await ref
                                                                          .get();
                                                                  if (snapshot
                                                                      .exists) {
                                                                    //reverse logic => if doc does exist it is the first message
                                                                    checkIfFirstMessage =
                                                                        false;
                                                                  } else {
                                                                    checkIfFirstMessage =
                                                                        true;
                                                                  }

                                                                  await ref
                                                                      .set({
                                                                    'senderUid': FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid,
                                                                    'receiverUid':
                                                                        uid,
                                                                    'lastMessage':
                                                                        data[
                                                                            'url'],
                                                                    'isRequestMessage':
                                                                        checkIfFirstMessage,
                                                                    'profileImageSender':
                                                                        profileImageUrl,
                                                                    'profileImageReceiver':
                                                                        _profileImage,
                                                                    'firstNameSender':
                                                                        firstName,
                                                                    'lastNameSender':
                                                                        lastName,
                                                                    'firstNameReceiver':
                                                                        _firstName,
                                                                    'lastNameReceiver':
                                                                        _lastName,
                                                                    'rollSender':
                                                                        roll,
                                                                    'rollReceiver':
                                                                        _roll,
                                                                  });
                                                                  String
                                                                      metaData =
                                                                      'Empty';

                                                                  try {
                                                                    print(data[
                                                                        'url']);
                                                                    print(data['url'].startsWith(
                                                                            'https://')
                                                                        ? data[
                                                                            'url']
                                                                        : 'https://${data['url']}');
                                                                    UrlMetadata
                                                                        metadata =
                                                                        await fetchUrlMetadata(data['url'].startsWith('https://')
                                                                            ? data['url']
                                                                            : 'https://${data['url']}');
                                                                    print(
                                                                        metaData);
                                                                    metaData = metadata.title ==
                                                                            ''
                                                                        ? data[
                                                                            'url']
                                                                        : metadata
                                                                            .title;
                                                                  } catch (e) {
                                                                    metaData =
                                                                        'Empty';
                                                                  }
                                                                  String docId =
                                                                      ref.id;
                                                                  ref.update({
                                                                    'docId':
                                                                        docId
                                                                  });
                                                                  DocumentReference
                                                                      messageRef =
                                                                      await ref
                                                                          .collection(
                                                                              'chat')
                                                                          .add({
                                                                    'message':
                                                                        data[
                                                                            'url'],
                                                                    'date': data[
                                                                        'date'],
                                                                    'time': data[
                                                                        'time'],
                                                                    'senderUid': FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid,
                                                                    'receiverUid':
                                                                        uid,
                                                                    'url':
                                                                        'google.com',
                                                                    'hasUrl':
                                                                        true,
                                                                    'metaData':
                                                                        metaData,
                                                                    'docId':
                                                                        'empty'
                                                                  });
                                                                  String
                                                                      messageDocId =
                                                                      messageRef
                                                                          .id;
                                                                  await messageRef
                                                                      .update({
                                                                    'docId':
                                                                        messageDocId
                                                                  });
                                                                }
                                                              }
                                                            }
                                                          }
                                                        } catch (e) {
                                                          print(e.toString());
                                                        }
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              pageBackgroundColor,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Center(
                                                          child: Image.asset(
                                                            'assets/messageIcon.png',
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Builder(builder:
                                                        (BuildContext context) {
                                                      return InkWell(
                                                        onTap: () async {
                                                          try {
                                                            // await Share.shareUri(Uri.parse(data['url']));
                                                            _onShare(context,
                                                                data['url']);
                                                          } catch (error) {
                                                            print(error
                                                                .toString());
                                                          }

                                                          //
                                                          // await Share.share(data['url'],).onError((error, stackTrace) {
                                                          //   print(error.toString());
                                                          // });
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxHeight: 22,
                                                                  minWidth: 60),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                pageBackgroundColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Center(
                                                            child: textRubik(
                                                                'Share',
                                                                selectedCategoryColor,
                                                                w400,
                                                                size12),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        try {
                                                          await createPDF(
                                                                  data['url'])
                                                              .then((value) {
                                                            print('saved');
                                                          });
                                                        } catch (e) {
                                                          print(e.toString());
                                                        }
                                                      },
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxHeight: 22,
                                                                minWidth: 60),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 4,
                                                                vertical: 3),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              pageBackgroundColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: textRubik(
                                                              'Print',
                                                              selectedCategoryColor,
                                                              w400,
                                                              size12),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        try {
                                                          String docId =
                                                              data['docId'];
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: textRoboto(
                                                                    "Delete URL",
                                                                    textColor,
                                                                    w500,
                                                                    size16),
                                                                content: textRubik(
                                                                    "Are you sure you want to delete this Url?",
                                                                    purple,
                                                                    FontWeight
                                                                        .w400,
                                                                    size13),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(); // Close the dialog
                                                                    },
                                                                    child: textRoboto(
                                                                        "Cancel",
                                                                        textColor,
                                                                        w400,
                                                                        size13),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      // Delete the document with the specified docId
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Categories')
                                                                          .doc(categoryProvider
                                                                              .title)
                                                                          .collection(
                                                                              'RecentLinks')
                                                                          .doc(
                                                                              docId)
                                                                          .delete();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(); // Close the dialog
                                                                    },
                                                                    child: textRoboto(
                                                                        "Confirm",
                                                                        Colors
                                                                            .teal,
                                                                        w500,
                                                                        size13),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } catch (e) {
                                                          print(e.toString());
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Link can't be deleted at the moment!");
                                                        }
                                                      },
                                                      child: Container(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxHeight: 22,
                                                                minWidth: 60),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 4,
                                                                vertical: 3),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              pageBackgroundColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                          child: textRubik(
                                                              'Delete',
                                                              selectedCategoryColor,
                                                              w400,
                                                              size12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                DottedLine(
                                                  direction: Axis.horizontal,
                                                  alignment:
                                                      WrapAlignment.center,
                                                  lineLength: double.infinity,
                                                  lineThickness: 1.0,
                                                  dashLength: 4.0,
                                                  dashColor: dottedDividerColor,
                                                  // dashGradient: [Colors.red, Colors.blue],
                                                  dashRadius: 0.0,
                                                  dashGapLength: 4.0,
                                                  dashGapColor:
                                                      Colors.transparent,
                                                  // dashGapGradient: [Colors.red, Colors.blue],
                                                  dashGapRadius: 0.0,
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        itemCount: docs.length,
                                        scrollDirection: Axis.vertical,
                                        physics: ClampingScrollPhysics(),
                                      );
                                    }
                                  });
                            })),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: textRoboto(
                      'Please Select a Category!', textColor, w400, size13),
                ),
        ),
        categoryProvider.title.isNotEmpty
            ? Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function()) setState) {
                              return AlertDialog(
                                backgroundColor: white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                scrollable: true,
                                shadowColor: textColor,
                                surfaceTintColor: offWhite,
                                semanticLabel: 'Add Link',
                                contentPadding: EdgeInsets.all(10),
                                content: Container(
                                  width: 400,
                                  height: 300,
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: isLoading2
                                      ? Center(
                                          child: CircularProgressIndicator(
                                              color: Colors.green))
                                      : Form(
                                          key: fKey,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 30, bottom: 15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(
                                                  'assets/logo.png',
                                                  width: 80,
                                                  height: 80,
                                                ),
                                                TextFormField(
                                                  controller:
                                                      addRecentLinkController,
                                                  validator: (v) {
                                                    return v!.length < 2
                                                        ? 'Invalid Link'
                                                        : null;
                                                  },
                                                  onFieldSubmitted: (v) async {
                                                    if (fKey.currentState!
                                                        .validate()) {
                                                      try {
                                                        String url =
                                                            addRecentLinkController
                                                                .text
                                                                .toString();
                                                        String metaData = url;
                                                        setState(() {
                                                          isLoading2 = true;
                                                        });

                                                        try {
                                                          UrlMetadata metadata =
                                                              await fetchUrlMetadata(
                                                                  url.startsWith(
                                                                          'https://')
                                                                      ? url
                                                                      : 'https://$url');
                                                          metaData = metadata
                                                                      .title ==
                                                                  ''
                                                              ? url
                                                              : metadata.title;
                                                        } catch (e) {
                                                          metaData = 'Empty';
                                                        }

                                                        final DateTime now =
                                                            DateTime.now();
                                                        final DateFormat
                                                            dateFormat =
                                                            DateFormat(
                                                                'dd MMM yyyy');
                                                        final DateFormat
                                                            timeFormat =
                                                            DateFormat(
                                                                'hh:mma');

                                                        String formattedDate =
                                                            dateFormat
                                                                .format(now);
                                                        String formattedTime =
                                                            timeFormat
                                                                .format(now);

                                                        final CollectionReference
                                                            recentLinksCollection =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Categories')
                                                                .doc(
                                                                    categoryProvider
                                                                        .title)
                                                                .collection(
                                                                    "RecentLinks");
                                                        List<String> readBy =
                                                            [];
                                                        // readBy.add(FirebaseAuth.instance.currentUser!.uid);
                                                        DocumentReference
                                                            newLinkDoc =
                                                            await recentLinksCollection
                                                                .add({
                                                          'senderUid':
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                          'url': url,
                                                          'date': formattedDate,
                                                          'time': formattedTime,
                                                          'metaData': metaData,
                                                          'readBy': readBy
                                                          // 'docId': '',  // No need to add this field initially
                                                        });

                                                        String newLinkDocId =
                                                            newLinkDoc.id;

// Now, update the 'docId' field with the actual document ID
                                                        await newLinkDoc
                                                            .update({
                                                          'docId': newLinkDocId
                                                        }).then((value) {
                                                          setState(() {
                                                            isLoading2 = false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      } catch (e) {
                                                        setState(() {
                                                          isLoading2 = false;
                                                        });
                                                        Navigator.pop(context);

                                                        print(e);
                                                      }
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: purple,
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: purple,
                                                              width: 2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: purple,
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12)),
                                                      errorBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.red,
                                                              width: 1.5),
                                                          borderRadius: BorderRadius.circular(12)),
                                                      hintText: 'Add a url'),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    if (fKey.currentState!
                                                        .validate()) {
                                                      try {
                                                        String url =
                                                            addRecentLinkController
                                                                .text
                                                                .toString();
                                                        String metaData = url;
                                                        setState(() {
                                                          isLoading2 = true;
                                                        });

                                                        try {
                                                          UrlMetadata metadata =
                                                              await fetchUrlMetadata(
                                                                  url.startsWith(
                                                                          'https://')
                                                                      ? url
                                                                      : 'https://$url');
                                                          metaData = metadata
                                                                      .title ==
                                                                  ''
                                                              ? url
                                                              : metadata.title;
                                                        } catch (e) {
                                                          metaData = 'Empty';
                                                        }

                                                        final DateTime now =
                                                            DateTime.now();
                                                        final DateFormat
                                                            dateFormat =
                                                            DateFormat(
                                                                'dd MMM yyyy');
                                                        final DateFormat
                                                            timeFormat =
                                                            DateFormat(
                                                                'hh:mma');

                                                        String formattedDate =
                                                            dateFormat
                                                                .format(now);
                                                        String formattedTime =
                                                            timeFormat
                                                                .format(now);

                                                        final CollectionReference
                                                            recentLinksCollection =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Categories')
                                                                .doc(
                                                                    categoryProvider
                                                                        .title)
                                                                .collection(
                                                                    "RecentLinks");
                                                        List<String> readBy =
                                                            [];
                                                        // readBy.add(FirebaseAuth.instance.currentUser!.uid);
                                                        DocumentReference
                                                            newLinkDoc =
                                                            await recentLinksCollection
                                                                .add({
                                                          'senderUid':
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                          'url': url,
                                                          'date': formattedDate,
                                                          'time': formattedTime,
                                                          'metaData': metaData,
                                                          'readBy': readBy
                                                          // 'docId': '',  // No need to add this field initially
                                                        });

                                                        String newLinkDocId =
                                                            newLinkDoc.id;

// Now, update the 'docId' field with the actual document ID
                                                        await newLinkDoc
                                                            .update({
                                                          'docId': newLinkDocId
                                                        }).then((value) {
                                                          setState(() {
                                                            isLoading2 = false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        });
                                                      } catch (e) {
                                                        setState(() {
                                                          isLoading2 = false;
                                                        });
                                                        Navigator.pop(context);

                                                        print(e);
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 150,
                                                    height: 45,
                                                    decoration: BoxDecoration(
                                                        color: btnBgColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        textRubik('Add', white,
                                                            w500, size14)
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              );
                            },
                          );
                        });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    width: 310,
                    height: 40,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: selectedCategoryColor.withOpacity(0.4),
                            spreadRadius: 1,
                            blurRadius: 1,
                          )
                        ],
                        color: btnBgColor,
                        borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          textRubik("+ Add new URL", white, w400, size14)
                        ],
                      ),
                    ),
                  ),
                ))
            : Container()
      ],
    );
  }

  _onShare(BuildContext context, String text) async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      text,
      subject: "-- I am Sharing this Link --",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  DateTime parseDateTime(String date, String time) {
    // Assuming the date format is "dd MMM yyyy" and time format is "hh:mma"
    String formattedDateTimeString = '$date $time';

    // Specify the date and time format used in your strings
    final format = DateFormat('dd MMM yyyy hh:mma');

    // Parse the formatted string into a DateTime object
    return format.parse(formattedDateTimeString);
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  List<Map<String, dynamic>> rootCategoriesList = [
    {
      'icon': 'categoryIcon1.png',
      'title': 'Administration',
      'isSelected': true,
    },
    {
      'icon': 'categoryIcon2.png',
      'title': 'Customer Service',
      'isSelected': false,
    },
    {
      'icon': 'categoryIcon3.png',
      'title': 'Sales & Marketing',
      'isSelected': false,
    },
    {
      'icon': 'categoryIcon4.png',
      'title': 'Operations',
      'isSelected': false,
    },
    {
      'icon': 'categoryIcon5.png',
      'title': 'Finance',
      'isSelected': false,
    },
    {
      'icon': 'categoryIcon6.png',
      'title': 'IT',
      'isSelected': false,
    },
    {
      'icon': 'categoryIcon7.png',
      'title': 'HR',
      'isSelected': false,
    },
    {
      'icon': 'categoryIcon8.png',
      'title': 'Security',
      'isSelected': false,
    }
  ];

  Widget rootCategories(double w, double h) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 200,
              height: h * 0.6,
              padding: EdgeInsets.only(left: 20),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  rootCategoriesList[index]['icon'],
                                  width: 25,
                                  height: 25,
                                ))),
                        SizedBox(
                          width: 12,
                        ),
                        Consumer<CategoryProvider>(
                          builder: (context, categoryProvider, _) {
                            return InkWell(
                              onTap: () {
                                // categoryProvider
                                //     .setTitle(data['categoryName']);
                                // categoryProvider.setSelectedIndex(index);
                              },
                              child: textRoboto(
                                // data['categoryName'],
                                // categoryProvider.categoryBoolList[index]
                                //     ? selectedCategoryColor
                                //     : textColor,
                                rootCategoriesList[index]['title'],
                                rootCategoriesList[index]['title']==roll
                                    ? selectedCategoryColor
                                    : textColor,
                                w400,
                                size16,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
                itemCount: 8,
                scrollDirection: Axis.vertical,
              )),
          SizedBox(
            height: h * 0.02,
          ),
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return addSubListDialog();
                    },
                  );
                },
              );
            },
            child: Container(
              height: 60,
              padding: EdgeInsets.only(left: w * 0.006),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/subListIcon.png',
                    width: 22,
                    height: 22,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  textRoboto('Add sublist', textColor, w400, size16)
                ],
              ),
            ),
          ),
          SizedBox(
            height: h * 0.05,
          ),
          Container(
            height: 60,
            padding: EdgeInsets.only(left: w * 0.006),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/settingsIcon1.png',
                  width: 22,
                  height: 22,
                ),
                SizedBox(
                  width: 12,
                ),
                textRoboto('Settings', textColor, w400, size16)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget categoryRow(double w, double h) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: h * 0.6,
            padding: EdgeInsets.only(left: 20),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        categoryProvider.add(false);
                        final data = docs[index].data();

                        return Container(
                          height: 60,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        data['categoryImage'],
                                        width: 25,
                                        height: 25,
                                      ))),
                              SizedBox(
                                width: 12,
                              ),
                              Consumer<CategoryProvider>(
                                builder: (context, categoryProvider, _) {
                                  return InkWell(
                                    onTap: () {
                                      categoryProvider
                                          .setTitle(data['docId']);
                                      categoryProvider.setSelectedIndex(index);
                                    },
                                    child: textRoboto(
                                      data['categoryName'],
                                      categoryProvider.categoryBoolList[index]
                                          ? selectedCategoryColor
                                          : textColor,
                                      w400,
                                      size16,
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: docs.length,
                      scrollDirection: Axis.vertical,
                    );
                  }
                }),
          ),
          SizedBox(
            height: h * 0.02,
          ),
          // GestureDetector(
          //   onTap: () async {
          //     await showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return StatefulBuilder(
          //           builder: (BuildContext context,
          //               void Function(void Function()) setState) {
          //             return addSubListDialog();
          //           },
          //         );
          //       },
          //     );
          //   },
          //   child: Container(
          //     height: 60,
          //     padding: EdgeInsets.only(left: w * 0.006),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Image.asset(
          //           'assets/subListIcon.png',
          //           width: 22,
          //           height: 22,
          //         ),
          //         SizedBox(
          //           width: 12,
          //         ),
          //         textRoboto('Add sublist', textColor, w400, size16)
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: h * 0.05,
          // ),
          // Container(
          //   height: 60,
          //   padding: EdgeInsets.only(left: w * 0.006),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Image.asset(
          //         'assets/settingsIcon1.png',
          //         width: 22,
          //         height: 22,
          //       ),
          //       SizedBox(
          //         width: 12,
          //       ),
          //       textRoboto('Settings', textColor, w400, size16)
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input; // Return an empty string if the input is empty
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  Widget linkLogRow(double w) {
    return Padding(
      padding: EdgeInsets.only(left: w * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          textRubik("${capitalizeFirstLetter(firstName)}'s Link Log", textColor,
              w500, size28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/contrassIcon.png',
                width: 25,
                height: 25,
              ),
              SizedBox(
                width: 10,
              ),
              textRoboto('Increase contrast', textColor, w400, size14),
              SizedBox(
                width: 15,
              ),
              Container(
                width: 1,
                height: size14,
                color: dottedDividerColor,
              ),
              SizedBox(
                width: 15,
              ),
              Image.asset(
                'assets/fontIcon.png',
                width: 20,
                height: 20,
              ),
              SizedBox(
                width: 10,
              ),
              textRoboto('Font size', textColor, w400, size14),
              SizedBox(
                width: 10,
              ),
              Slider(
                value: sliderVal,
                onChanged: (v) {
                  setState(() {
                    sliderVal = v;
                  });
                },
                thumbColor: textColor,
                activeColor: textColor,
                secondaryActiveColor: textColor,
                min: 0.1,
                max: 0.9,
                inactiveColor: lightestGrey,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget appBar(double w, String username, String roll, String _imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 55,
              height: 55,
            ),
            SizedBox(
              width: 10,
            ),
            Image.asset(
              'assets/logoText.png',
              height: size24,
            ),
            SizedBox(
              width: 50,
            ),
            Container(
              width: w * 0.4,
              height: 40,
              decoration: BoxDecoration(
                color: offWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/searchIcon.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: searchFieldController,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            color: textColor,
                            letterSpacing: .5,
                            fontWeight: w400,
                            fontSize: size14),
                      ),
                      cursorColor: textColor,
                      decoration: InputDecoration.collapsed(
                        hintText:
                            'Search keywords, URLs, links or meta descriptions',
                        hintStyle: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              color: textColor,
                              letterSpacing: .5,
                              fontWeight: w400,
                              fontSize: size14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/notificationIcon.png',
              width: 40,
              height: 40,
            ),
            SizedBox(
              width: w * 0.006,
            ),
            InkWell(
              onTap: () async {
                await _selectAndDisplayImage().then((value) async {
                  if (_imageFileDP != null) {
                    await _uploadImageDP().then((value) async {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'imageUrl': imageUrlDP.isNotEmpty
                            ? imageUrlDP
                            : 'https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/profileImagePlaceHolder.png?alt=media&token=9d64cc25-ec5e-4360-9bd4-0c0663c2f143'
                      }).then((value) {
                        setState(() {
                          _imageUrl = imageUrlDP;
                        });
                      });
                    });
                  }
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrlDP.isNotEmpty ? imageUrlDP : _imageUrl,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: w * 0.0055,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                textRoboto(username, textColor, w500, size16),
                SizedBox(
                  height: 4,
                ),
                textRubik(roll, textColor, w400, size10),
              ],
            ),
            SizedBox(
              width: w * 0.005,
            ),
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
                              builder: (context) => LoginScreen()));
                    });
                  } catch (e) {
                    print(e.toString());
                  }
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
                  // You can add more items if needed
                ];
              },
            ),
            SizedBox(
              width: w * 0.005,
            ),
          ],
        )
      ],
    );
  }

  File? _imageFile;
  File? _imageFileDP;

  final picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  Future<void> _selectAndDisplayImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _imageFileDP = File(pickedFile.path);
    });
    print(_imageFileDP);
  }

  String categoryImageUrl = "";
  String imageUrlDP = "";
  bool isSelected = false;
  bool isSelectedDP = false;

  Future<bool> _uploadImage() async {
    try {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an image first.'),
          ),
        );
        isSelected = false;
        return isSelected;
      }

      final fileName = _imageFile!.path.split('/').last;

      final ref = await _storage.ref().child('images/$fileName');

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFile!.path).readAsBytes();

        UploadTask uploadTask = ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/png'),
        );

        // TaskSnapshot snapshot = await uploadTask;

        final imageUrl = await ref.getDownloadURL();

        setState(() {
          categoryImageUrl = imageUrl;
          isSelected = true;
        });

        return isSelected;
      } else {
        await ref.putFile(_imageFile!);
      }

      final imageUrl = await ref.getDownloadURL();

      setState(() {
        categoryImageUrl = imageUrl;
        isSelected = true;
      });
      return isSelected;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> _uploadImageDP() async {
    try {
      if (_imageFileDP == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an image first.'),
          ),
        );
        isSelectedDP = false;
        return isSelectedDP;
      }

      final fileName = _imageFileDP!.path.split('/').last;

      final ref = await _storage.ref().child('images/$fileName');

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFileDP!.path).readAsBytes();

        UploadTask uploadTask = ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/png'),
        );

        // TaskSnapshot snapshot = await uploadTask;

        final imageUrl = await ref.getDownloadURL();

        setState(() {
          imageUrlDP = imageUrl;
          isSelectedDP = true;
        });

        return isSelectedDP;
      } else {
        await ref.putFile(_imageFileDP!);
      }

      final imageUrl = await ref.getDownloadURL();

      setState(() {
        imageUrlDP = imageUrl;
        isSelectedDP = true;
      });
      return isSelectedDP;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Widget addSubListDialog() {
    bool isLoading2 = false;
    final fKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Container(
            width: 350,
            height: 200,
            child: isLoading2
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.green,
                    ),
                  )
                : Form(
                    key: fKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        textRoboto('Add Sublist', textColor, w600, size18),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            // await _selectAndDisplayImage();

                            try {
                              final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedFile == null) return;
                              setState(() {
                                _imageFile = File(pickedFile.path);
                              });
                              print('file selected');
                              print(_imageFile);
                            } catch (e) {
                              print(e.toString());
                            }
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: _imageFile == null
                                  ? Image.asset(
                                      'assets/profileImagePlaceHolder.png',
                                      fit: BoxFit.cover,
                                      width: 35,
                                      height: 35,
                                    )
                                  : Image.network(
                                      _imageFile!.path,
                                      fit: BoxFit.cover,
                                      width: 35,
                                      height: 35,
                                    )),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          validator: (v) {
                            return v!.length < 2
                                ? 'Please enter a sublist name'
                                : null;
                          },
                          controller: sublistController,
                          decoration: InputDecoration(
                            labelText: 'Sublist Name',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            errorBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.indigo, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.indigo, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (fKey.currentState!.validate()) {
                              String subListName =
                                  sublistController.text.toString();
                              try {
                                setState(() {
                                  isLoading2 = true;
                                });
                                bool uploaded = await _uploadImage();

                                final DocumentReference docRef =
                                    FirebaseFirestore.instance
                                        .collection('Categories')
                                        .doc(subListName);
                                // Check if the document already exists
                                final DocumentSnapshot docSnapshot =
                                    await docRef.get();

                                if (docSnapshot.exists) {
                                  // Document already exists, update the fields
                                  // await FirebaseFirestore.instance.collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists').add(data)

                                  await docRef.update({
                                    'categoryName': subListName,
                                    'categoryImage': uploaded
                                        ? categoryImageUrl
                                        : "https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/subListIcon.png?alt=media&token=76b450e4-4f50-45c7-a093-7ba5c8627e0b"
                                  }).then((value) {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading2 = false;
                                    });
                                  });
                                } else {
                                  // Document does not exist, create it
                                  await docRef.set({
                                    'categoryName': subListName,
                                    'categoryImage': uploaded
                                        ? categoryImageUrl
                                        : "https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/subListIcon.png?alt=media&token=76b450e4-4f50-45c7-a093-7ba5c8627e0b"
                                  }).then((value) {
                                    Navigator.pop(context);
                                    setState(() {
                                      isLoading2 = false;
                                    });
                                  });
                                }
                              } catch (e) {
                                Navigator.pop(context);
                                print(e.toString());
                                setState(() {
                                  isLoading2 = false;
                                });
                              }
                            }
                            // Handle the button press (e.g., save the sublist)
                            // Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.indigo,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text('Add', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

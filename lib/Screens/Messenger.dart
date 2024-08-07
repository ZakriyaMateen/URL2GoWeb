import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
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
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Properties/fontWeights.dart';
import 'package:url2goweb/Screens/AuthScreens/CorpLogin.dart';
import 'package:url2goweb/Screens/recentLinksMainCategorySearch.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MetaDataFetch/MetaData.dart';
import '../Properties/fontSizes.dart';
import '../Providers/CategoryProvider.dart';
import '../Providers/CategoryProviderMessenger.dart';
import '../Providers/ContactSearchProvider.dart';
import '../Providers/FontSizeProvider.dart';
import '../Providers/UnreadMessagesDashboardProvider.dart';
import '../Providers/recentLinksTabProvider.dart';
import '../Providers/searchProvider.dart';
import '../Utils/TextHasUrlAndExtractedUrl.dart';
import 'AuthScreens/EmployeeLogin.dart';
import 'AuthScreens/LoginScreen.dart';
import 'AuthScreens/LoginScreenUser.dart';

class Messenger extends StatefulWidget {

  final String globalChatReceiverProfileImage;
  final String globalchatReceiverUsername;
  final String globalchatReceiverRoll;
  final String globalchatDocId;
  final String globalchatReceiverUid;
  final String globalisRequestMessage;
  final bool followEachother;
  const Messenger({Key? key, required this.globalChatReceiverProfileImage, required this.globalchatReceiverUsername, required this.globalchatReceiverRoll, required this.globalchatDocId, required this.globalchatReceiverUid, required this.globalisRequestMessage, required this.followEachother}) : super(key: key);

  @override
  State<Messenger> createState() => _MessengerState();
}

class _MessengerState extends State<Messenger> {
  @override
  void dispose() {
    super.dispose();
    // Remember to remove the event listener when the widget is disposed
    html.window.removeEventListener('beforeunload', (event) {});
    searchFieldController.dispose();
    sublistController.dispose();
    chatController.dispose();
    searchUrlController.dispose();
  }
  List<Map<String, dynamic>> rootCategoriesList = [
    {
      'icon': 'assets/categoryIcon1.png',
      'title': 'Administration',
      'isSelected': true,
    },
    {
      'icon': 'assets/categoryIcon2.png',
      'title': 'Customer Service',
      'isSelected': false,
    },
    {
      'icon': 'assets/categoryIcon3.png',
      'title': 'Sales & Marketing',
      'isSelected': false,
    },
    {
      'icon': 'assets/categoryIcon4.png',
      'title': 'Operations',
      'isSelected': false,
    },
    {
      'icon': 'assets/categoryIcon5.png',
      'title': 'Finance',
      'isSelected': false,
    },
    {
      'icon': 'assets/categoryIcon6.png',
      'title': 'IT',
      'isSelected': false,
    },
    {
      'icon': 'assets/categoryIcon7.png',
      'title': 'HR',
      'isSelected': false,
    },
    {
      'icon': 'assets/categoryIcon8.png',
      'title': 'Security',
      'isSelected': false,
    }
  ];

  String roll='';
  String profileImageUrl='';
  String firstName='';
  String lastName='';
  String email ='';
  String corporationEmail ='';
  String corporationName ='';
  bool isLoading=true;
  Future<String> getUserCorpDetailsFromAllUsersCollection()async{
    String corpEmail = 'empty';
    try{
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection('AllUsers').doc(FirebaseAuth.instance.currentUser!.uid).get();
      String corpEmail = await snap['corporationEmail'];
      corporationEmail = corpEmail;
      return corpEmail;
    }
    catch(e){
      print(e.toString());
      return corpEmail;
    }
  }  Future<void> getUserDetails ()async{
    try{
      await getUserCorpDetailsFromAllUsersCollection().then((corpEmail) async{
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(corpEmail).doc(corpEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
        String _roll = await snapshot['roll'];
        String _firstName = await snapshot['firstName'];
        String _lastName = await snapshot['lastName'];
        String _profileImage = await snapshot['imageUrl'];
        String _email = await snapshot['email'];
        String _corpName = await snapshot['corporationName'];
        String _corpEmail = await snapshot['corporationEmail'];

        if(_roll.isNotEmpty&&_firstName.isNotEmpty&&_lastName.isNotEmpty&&_profileImage.isNotEmpty&&_email.isNotEmpty){

          setState(() {
            firstName= _firstName;
            lastName= _lastName;
            profileImageUrl= _profileImage;
            email= _email;
            roll=_roll;
            corporationEmail = corpEmail;
            corporationName = _corpName;
          });
        }
        // print(profileImageUrl);
        setState(() {
          isLoading=false;
        });
      });

    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textCenter('Please sign in again!', white, w400, size13),));
      Fluttertoast.showToast(msg: 'Please sign in again');
      print(e.toString());
    }
  }
  Future<void> getUserDetails_X_getRequestsReceived_X_getMyFollowings_X_getAllUserIds()async{
    try{
      await getUserDetails().then((value) async{
        await getAllUserIds().then((value) async{
        await  getRequestsReceived();
         getMyFollowings();
        });
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setGlobalVariablesToReceivedFromWidget();
    getUserDetails_X_getRequestsReceived_X_getMyFollowings_X_getAllUserIds();
    html.window.addEventListener('beforeunload', (event) async{
      // Custom code to handle browser/tab closing
      // You can add your logic here
      await updateMyOnlineStatus(false);
    });
    // stream();
  }

  String globalChatReceiverProfileImage='';
  String globalchatReceiverUsername='';
  String globalchatReceiverRoll='';
  String globalchatDocId='';
  String globalchatReceiverUid='';
  String globalisRequestMessage='';
  bool followEachOther = false;
  final ScrollController _scrollController = ScrollController();

  void setGlobalVariablesToReceivedFromWidget(){
    globalChatReceiverProfileImage=widget.globalChatReceiverProfileImage;
    globalchatReceiverUsername=widget.globalchatReceiverUsername;
    globalchatReceiverRoll=widget.globalchatReceiverRoll;
    globalchatDocId=widget.globalchatDocId;
    globalchatReceiverUid=widget.globalchatReceiverUid;
    globalisRequestMessage=widget.globalisRequestMessage;
    // user2_Uid = FirebaseAuth.instance.currentUser!.uid;
    user2_Uid = widget.globalchatReceiverUid;
    followEachOther = widget.followEachother;

    user1_Uid = FirebaseAuth.instance.currentUser!.uid;
  }
  Future<void> updateMyOnlineStatus(bool status)async{
    try{
      DocumentReference onlineRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid);
      await onlineRef.update({
        'isOnline':false
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  double sliderVal = 0.2;
  TextEditingController searchFieldController = TextEditingController();
  TextEditingController chatController = TextEditingController();
  TextEditingController searchUrlController = TextEditingController();
  TextEditingController sublistController = TextEditingController();
  final TransformationController _transformationController = TransformationController();
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _scale = _scale == 1.0 ? 2.0 : 1.0; // Toggle between zoom in and zoom out
          _transformationController.value = Matrix4.diagonal3Values(_scale, _scale, 1.0);
        });
      },
      child: WillPopScope(

        onWillPop: () async{
          await updateMyOnlineStatus(false).then((value) {
            return true;
          });
          return true;
          },
        child: Scaffold(
          backgroundColor: pageBackgroundColor,
          body:isLoading?Center(child: CircularProgressIndicator(color: Colors.green,),):
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: w,
                  height: 8,
                  color: purple,
                ),
                Padding(
                  padding:  EdgeInsets.only(left: 18,right: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 8),
                        w>800?
                        appBar(w,capitalizeFirstLetter(firstName)+" "+capitalizeFirstLetter(lastName),roll,profileImageUrl):
                        appBarMobile(w,capitalizeFirstLetter(firstName)+" "+capitalizeFirstLetter(lastName),roll,profileImageUrl),
                        SizedBox(height: 38,),
                       w>800? linkLogRow(w): linkLogRowMobile(w),
                        SizedBox(height: 20,),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              rootCategories(w, h),
                              SizedBox(width: w*0.03,),
                              urlsSearchContainer_OR_contactsContainer(w, h),
                              SizedBox(width: w*0.012,),
                              chatContainerUpdated(w, h)
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
        ),
      ),
    );
  }
  FocusNode chatFocusNode = FocusNode();
  String selectedCategory = '';
  Widget rootCategories(double w, double h) {
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 220 * fontSizeProvider.fontSizeMultiplier,
              height: h * 0.6,
              padding: EdgeInsets.only(left: 20 * fontSizeProvider.fontSizeMultiplier),
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
                                  width: 25 * fontSizeProvider.fontSizeMultiplier,
                                  height: 25 * fontSizeProvider.fontSizeMultiplier,
                                ))),
                        SizedBox(
                          width: 12 * fontSizeProvider.fontSizeMultiplier,
                        ),
                          Consumer<CategoryProviderMessenger>(
                          builder: (context, categoryProvider, _) {
                            return InkWell(
                              onTap: () {
                                setState((){
                                  selectedCategory = rootCategoriesList[index]['title'];
                                });
                                  for(int i=0; i < rootCategoriesList.length;i++){
                                    if(index!=i){
                                      setState(() {
                                        rootCategoriesList[i]['isSelected']=false;
                                      });
                                    }
                                  }
                                 setState(() {
                                   rootCategoriesList[index]['isSelected']=!rootCategoriesList[index]['isSelected'];
                                 });
                                  if( rootCategoriesList[index]['isSelected']==false){
                                    setState(() {
                                      selectedCategory='';
                                    });
                                  }
                                categoryProvider.reset();
                              },
                              child: textRoboto(
                                rootCategoriesList[index]['title'],
                                rootCategoriesList[index]['isSelected']
                                    ? selectedCategoryColor
                                    : textColor,
                                w400,
                                size16*fontSizeProvider.fontSizeMultiplier,
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
          SizedBox(
            height: h * 0.05,
          ),

        ],
      ),
    );
  }
  Widget chatContainerUpdated(double w, double h ){
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: false);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            textRubik('',textColor,w500, size28 * fontSizeProvider.fontSizeMultiplier)
          ],
        ),
        SizedBox(height: 15,),
      !followEachOther?  Container(
          width: 800,
          height: h*0.76,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(8),),
          child: Center(
            child: textRubik("You do not follow each other", selectedCategoryColor, w500, size17 * fontSizeProvider.fontSizeMultiplier),
          ),
        ):
        Container(
          width: 800,
          height: h*0.76,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(8),),
          child: Stack(
            children: [
              Align(
                alignment:Alignment.topCenter,
                child: Container(
                  width: 800,
                  height: 90,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(globalChatReceiverProfileImage,width: 45 * fontSizeProvider.fontSizeMultiplier,height: 45 * fontSizeProvider.fontSizeMultiplier,fit: BoxFit.cover,),
                                ),
                                SizedBox(width: 12 * fontSizeProvider.fontSizeMultiplier,),
                                textRubik(globalchatReceiverUsername, textColor, w500,size22*fontSizeProvider.fontSizeMultiplier)
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 800,
                  height: h*0.65,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(8),),

                  // child: messages,

                  child:   globalchatDocId==''?Center(child:textRubik('Start a Conversation', blue,w500,size12)):
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Chats').doc(globalchatDocId).collection('Messages').orderBy('timeStamp',descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No messages yet.'));
                      }
                      final messages = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          // var message = messages[index].data() as Map<String, dynamic>;
                          final message = messages[index].data();
                          try{
                            return index==0?Padding(
                              padding: const EdgeInsets.only(bottom: 100),
                              child: buildMessage(message),
                            ):buildMessage(message);
                          }
                          catch(e){
                            print(e.toString());
                              return Container();
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 200,),

              Positioned(bottom:0,
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 800,
                      height: 2,
                      child: Divider(thickness: 1.6,color: pageBackgroundColor,)),
                  Container(
                    width: 800,
                    height: 70,
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      width: 780,
                      height: 40,
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: TextFormField(
                              focusNode: chatFocusNode,
                              controller: chatController,
                              style:  GoogleFonts.roboto(
                                textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14),
                              ),
                              cursorColor: textColor,
                              decoration: InputDecoration.collapsed(hintText: 'Start typing here...',
                                hintStyle:  GoogleFonts.roboto(
                                  textStyle: TextStyle(color: textColorLight, letterSpacing: .5,fontWeight: w400,fontSize: size14),
                                ),
                              ),
                              onFieldSubmitted: (v)async{
                                if(v.toString().isNotEmpty){

                                  chatController.clear();
                                  chatFocusNode.requestFocus();
                                  sendMessage(v);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 6,),
                          InkWell(
                              onTap:  ()async{
                                if(chatController.text.isNotEmpty){
                                  sendMessage(chatController.text.toString()).then((value) {
                                    chatController.clear();
                                    chatFocusNode.requestFocus();
                                  });

                                }
                              },
                              child: Image.asset('assets/sendMessageIcon.png',width: 20,height: 20,)),
                          SizedBox(width: 8,),

                        ],

                      ),
                    ),
                  ),
                ],
              ))

            ],
          ),
        ),
      ],
    );
  }


  Future<void> sendMessage(String v)async{
    TextHasUrlAndExtractedUrl urlInfo = extractUrlInfo(v!.toString());

    // print("Has URL: ${urlInfo.hasUrl}");
    // print("URL: ${urlInfo.url}");

    String text = v.toString();

    try{

      String metaData='Empty';

      if(urlInfo.hasUrl){
        try{
          UrlMetadata metadata = await fetchUrlMetadata(urlInfo.url.startsWith('https://')?urlInfo.url:'https://$urlInfo.url');
          metaData  =metadata.title==''?urlInfo.url:metadata.title;
        }
        catch(e){
          metaData='Empty';
        }
      }
      DateTime now = DateTime.now();

      String formattedTime = formatTime(now);
      String formattedDate = formatDate(now);
      DocumentReference ref=  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Chats').doc(globalchatDocId).collection('Messages').add(
          {
            'receiverUid':user2_Uid,
            'senderUid':user1_Uid,
            // 'receiverUid':globalchatReceiverUid,
            // 'senderUid':globalchatReceiverUid,
            'time':formattedTime,
            'date':formattedDate,
            'timeStamp':DateTime.now(),
            'hasUrl':urlInfo.hasUrl,
            'metaData':metaData,
            'url':urlInfo.hasUrl?urlInfo.url:'Empty',
            'message':v.toString(),
            'docId':'empty'
          });
      await ref.update({
        'docId':ref.id
      });
    }
    catch(e){
      print(e.toString());
    }
    try{

      DocumentReference chatRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(globalchatReceiverUid);
      DocumentSnapshot chatSnap = await chatRef.get();


        String unreadMessages = await chatSnap[FirebaseAuth.instance.currentUser!.uid];
        chatRef.update({
          FirebaseAuth.instance.currentUser!.uid : (int.parse(unreadMessages)+1).toString()
        });

    }
    catch(e){
      DocumentReference chatRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(globalchatReceiverUid);
      DocumentSnapshot chatSnap = await chatRef.get();

      chatRef.update({
        FirebaseAuth.instance.currentUser!.uid :'1'
      });
      print(e.toString());
    }

  }

  Widget buildMessage(var message){
    bool isMine = message['senderUid']==FirebaseAuth.instance.currentUser!.uid;
    // print(isMine);
    // print(message['senderUid']);
  bool hasUrl=message['hasUrl'];
  bool metaDataNotEmpty = message['metaData']!='Empty';

  String url = message['url'];
  String data = message['date'];
  String time = message['time'];
  String docId = message['docId'];
  FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context);
   bool isUrlList =  message['message'].toString().contains('https')||message['message'].toString().contains('.com');
   print(isUrlList);
    List<String> urls = [];
    if(isUrlList){
    urls = message['message'].toString().split(',').map((e) => e.trim()).toList();
    print(urls);
   }
    return
      metaDataNotEmpty?Row(
        mainAxisAlignment: isMine?MainAxisAlignment.end:MainAxisAlignment.start,
        children: [
          GestureDetector(
            onSecondaryTapDown: isMine?(v){
              _showDeleteDialog(docId);
            }:(v){},
            child: Container(
              margin: EdgeInsets.only(left: isMine?100 * fontSizeProvider.fontSizeMultiplier:16 * fontSizeProvider.fontSizeMultiplier,right:isMine?16 * fontSizeProvider.fontSizeMultiplier:100 * fontSizeProvider.fontSizeMultiplier,bottom: 8 * fontSizeProvider.fontSizeMultiplier,top: 5 * fontSizeProvider.fontSizeMultiplier),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isMine?CrossAxisAlignment.end:CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: ()async{
                      await launchUrl(Uri.parse(url));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       isMine? Icon(CupertinoIcons.link,color:Colors.grey[800]! ,):Container(),
                        Container(
                          decoration: BoxDecoration(
                              color: white,
                              border: Border(left:isMine? BorderSide(color: pageBackgroundColor,width: 3): BorderSide(color: white,width: 0),
                                right:!isMine? BorderSide(color: pageBackgroundColor,width: 3): BorderSide(color: white,width: 0), )
                          ),
                          margin: EdgeInsets.only(bottom: 7 * fontSizeProvider.fontSizeMultiplier),
                          padding: EdgeInsets.only(left: isMine?7 * fontSizeProvider.fontSizeMultiplier:0,right: !isMine?7 * fontSizeProvider.fontSizeMultiplier:0),
                          child: textRobotoMessage(message['metaData'].toString().length>60?message['metaData'].toString().substring(0,43):message['metaData'].toString(),textColor==Colors.grey[300]!?Colors.grey[800]!: textColor, w500,size18),
                        ),
                       ! isMine? Icon(CupertinoIcons.link,color:Colors.grey[800]! ,):Container(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: isMine?MainAxisAlignment.end:MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      textRubik(isMine?"Me ":globalchatReceiverUsername, textColorLight,w400,size11 * fontSizeProvider.fontSizeMultiplier),
                      textRubik(time, textColorLight,w400,size11 * fontSizeProvider.fontSizeMultiplier),
                    ],
                  ),
                  SizedBox(height: 2 * fontSizeProvider.fontSizeMultiplier,),
                  Container(padding:  EdgeInsets.only(left: 10 * fontSizeProvider.fontSizeMultiplier,right: 10 * fontSizeProvider.fontSizeMultiplier,top: 7 * fontSizeProvider.fontSizeMultiplier,bottom: 7 * fontSizeProvider.fontSizeMultiplier),
                    alignment: Alignment.center,
                    constraints:  message['message'].toString().length>60?const BoxConstraints(
                        minWidth: 50,
                        minHeight: 26,
                        maxWidth: 500
                    ):const BoxConstraints(
                      minWidth: 50,
                      minHeight: 26,
                    ),
                    decoration: BoxDecoration(
                      color: isMine?messageColor:pageBackgroundColor,
                      borderRadius: BorderRadius.circular(10),

                    ),child:
                    SelectableText(
                        onTap: () async{
                          url.contains('https')?
                          await launchUrl(Uri.parse(url)):
                          await launchUrl(Uri.parse('https://'+url));
                        },
                        url,
                        style: GoogleFonts.roboto(
                            textStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize:size17,fontWeight: w500,overflow: TextOverflow.visible)
                        )
                    ),
                    // textRobotoMessage(message['message'],textColor==Colors.grey[300]!?Colors.grey[800]!:textColor,w400, size16 * fontSizeProvider.fontSizeMultiplier),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          :
      Row(
        mainAxisAlignment: isMine?MainAxisAlignment.end:MainAxisAlignment.start,
        children: [
          GestureDetector(
            onSecondaryTapDown: isMine? (v){
              _showDeleteDialog(docId);
            }:(v){},
            onTap: ()async{
              if(url!='Empty'){
                await launchUrl(Uri.parse(url));
              }
            },
            child: Container(
              margin: EdgeInsets.only(left: isMine?100 * fontSizeProvider.fontSizeMultiplier:16 * fontSizeProvider.fontSizeMultiplier,right:isMine?16 * fontSizeProvider.fontSizeMultiplier:100 * fontSizeProvider.fontSizeMultiplier,bottom: 8 * fontSizeProvider.fontSizeMultiplier,top: 5 * fontSizeProvider.fontSizeMultiplier),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isMine?CrossAxisAlignment.end:CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: isMine?MainAxisAlignment.end:MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      textRubik(isMine?"Me ":globalchatReceiverUsername, textColorLight,w400,size11 * fontSizeProvider.fontSizeMultiplier),
                      textRubik(time, textColorLight,w400,size11 * fontSizeProvider.fontSizeMultiplier),
                    ],
                  ),
                  SizedBox(height: 2 * fontSizeProvider.fontSizeMultiplier,),
                  //
                  // isUrlList?
                      urls.isNotEmpty?
                      Container(
                        padding: EdgeInsets.only(left: 10 * fontSizeProvider.fontSizeMultiplier,right: 10 * fontSizeProvider.fontSizeMultiplier,top: 7 * fontSizeProvider.fontSizeMultiplier,bottom: 7 * fontSizeProvider.fontSizeMultiplier),
                        alignment: Alignment.center,
                        constraints:  message['message'].toString().length>80?BoxConstraints(
                            minWidth: 50,
                            minHeight: 26,
                            maxWidth: 250
                        ):BoxConstraints(
                          minWidth: 50,
                          minHeight: 26,
                        ),
                        decoration: BoxDecoration(
                          color: isMine?messageColor:pageBackgroundColor,
                          borderRadius: BorderRadius.circular(10),

                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (String url in urls)
                              Container(
                                constraints:message['message'].toString().length>80?BoxConstraints(
                                    minWidth: 50,
                                    minHeight: 26,
                                    maxWidth: 250
                                ):BoxConstraints(
                                  minWidth: 50,
                                  minHeight: 26,
                                ),
                                child: SelectableText(
                                    onTap: () async{
                                      url.contains('https')?
                                      await launchUrl(Uri.parse(url)):
                                      await launchUrl(Uri.parse('https://'+url));
                                    },
                                    url,
                                    style: GoogleFonts.roboto(
                                        textStyle: TextStyle(color: Theme.of(context).primaryColor, fontSize:size17,fontWeight: w500,overflow: TextOverflow.visible)
                                    )
                                ),
                              )

                          ],
                        ),
                      ) ://
                  Container(
                    child: SelectableText(
                      message['message']!,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(color:textColor==Colors.grey[300]!?Colors.grey[800]!: textColor, letterSpacing: .5, fontWeight: w400, fontSize: size16 * fontSizeProvider.fontSizeMultiplier),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 10 * fontSizeProvider.fontSizeMultiplier,right: 10 * fontSizeProvider.fontSizeMultiplier,top: 7 * fontSizeProvider.fontSizeMultiplier,bottom: 7 * fontSizeProvider.fontSizeMultiplier),
                    alignment: Alignment.center,
                    constraints:  message['message'].toString().length>80?BoxConstraints(
                        minWidth: 50,
                        minHeight: 26,
                        maxWidth: 500
                    ):BoxConstraints(
                      minWidth: 50,
                      minHeight: 26,
                    ),
                    decoration: BoxDecoration(
                      color: isMine?messageColor:pageBackgroundColor,
                      borderRadius: BorderRadius.circular(10),

                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: textRoboto("Delete Message",textColor,w500,size16),
          content: textRubik("Are you sure you want to delete this message?", purple, FontWeight.w400, size13),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: textRoboto("Cancel",textColor,w400,size13),
            ),
            TextButton(
              onPressed: () async {
                // Delete the document with the specified docId
                try{
                  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Chats').doc(globalchatDocId).collection('Messages').doc(docId).delete();

                }
                catch(e){
                  print(e.toString());
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: textRoboto("Confirm",Colors.teal,w500,size13),
            ),
          ],
        );
      },
    );
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mma').format(dateTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM y').format(dateTime);
  }


  String chatReceiverProfileImage='';
  String chatReceiverUsername='';
  String chatReceiverRoll='';
  String chatDocId='';
  String chatReceiverUid='';
  String isRequestMessage='';

  String generateChatId(String userId1, String userId2) {
    // Create a list containing the user IDs
    List<String> userIds = [userId1, userId2];

    // Sort the user IDs alphabetically
    userIds.sort();

    // Join the sorted user IDs with an underscore to create the chat ID
    String chatId = userIds.join('_');

    // Return the generated chat ID
    return chatId;
  }
  List<String> allUids = [];
  String contactSearchText = '';
  List<Map<String,dynamic>> unread = [
    {
    }
  ];
  List<String> allUsersUids = [];

// Define a function to repeatedly call getAllUserIds() every 5 seconds
  Future<void> stream() async {
    // Define an asynchronous function to perform the repetitive task
    Future<void> repeatTask() async {
      try {
         getAllUserIds(); // Call getAllUserIds() and wait for it to complete
      } catch (e) {
        print(e.toString()); // Print any error that occurs
      }

      // Schedule the repeatTask to execute again after 5 seconds
      await Future.delayed(Duration(seconds: 5));
      await repeatTask(); // Recursive call to repeat the task
    }

    // Start the repetitive task
    await repeatTask();
  }

  Future<void> getAllUserIds() async {
      List<String> userIds = [];
    try {
      // Get the snapshot of all documents in the 'Users' collection
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').get();

      // Iterate through each document to extract the 'uid' field
      snapshot.docs.forEach((doc) {
        String uid = doc.get('uid');
        // Add the uid to the list
        if (uid != null) {
          userIds.add(uid);
        }
        else{
          userIds.add('null');
        }
      });
      setState(() {
        allUsersUids = userIds;
      });
      UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context,listen: false);
      unreadMessagesDashboardProvider.getAllPeopleUnreadMessages(allUsersUids,corporationEmail);
      //uncomment this
      asynchronousUnreadMessages();
    } catch (e) {
      // Handle any errors
      print("Error getting user IDs: $e");
    }
  }

  Future<void> asynchronousUnreadMessages () async {
    UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context, listen: false);

    // Schedule a task to execute every 5 seconds
    Timer.periodic(Duration(seconds: 45), (timer) async {
      unreadMessagesDashboardProvider.reset();
      await unreadMessagesDashboardProvider.getAllPeopleUnreadMessages(allUsersUids,corporationEmail);
    });
  }
  List<String> myFollowing = [];
  List<String> requestsReceived = [];
  void getMyFollowings()async{
    try{
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      List<String> myFollowings = List.from(await snap['myFollowings']) ;
      if(myFollowings.isNotEmpty){
        myFollowing = myFollowings;
        print("MyFollowing fun: "+myFollowings.toString());
      }
      print("MyFollowing fun: "+myFollowings.toString());


    }
    catch(e){
      print('heyyy'+e.toString());
    }
  }
  void getMyFollowingsRefresh()async{
    try{
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      List<String> myFollowings = List.from(await snap['myFollowings']) ;
      if(myFollowings.isNotEmpty){
        setState(() {
          myFollowing = myFollowings;
        });
        print("MyFollowing fun: "+myFollowings.toString());
      }
      print("MyFollowing fun: "+myFollowings.toString());


    }
    catch(e){
      print(e.toString());
    }
  }

  Future<void> getRequestsReceived()async{
    try{
      DocumentSnapshot requestsReceivedSnap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      requestsReceived = List.from(await requestsReceivedSnap['requestList']);

    }
    catch(e){
      print(e.toString);
    }
  }
  Future<void> getRequestsReceivedRefresh()async{
    try{
      DocumentSnapshot requestsReceivedSnap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      List<String> requestsReceived2 = List.from(await requestsReceivedSnap['requestList']);
      setState(() {
        requestsReceived = requestsReceived2;
      });
    }
    catch(e){
      print(e.toString);
    }
  }

  bool showRequests = false;


  String chat_DocId = '';
  String user1_Uid = '';
  String user2_Uid = '';
  String  user2_Uid_ForSetState = '';
  Widget urlsSearchContainer_OR_contactsContainer(double w, double h){
    final categoryProvider = Provider.of<CategoryProvider>(context);
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return Consumer<SearchProvider>(builder: (context,searchProvider,_){
      return searchProvider.searchText==''?contactsContainer(w,h):
      recentLinksMainCategorySearch(w, h, roll, categoryProvider,fontSizeProvider, profileImageUrl, firstName, lastName,searchProvider.searchText,context,corporationEmail);

    });
  }
  Widget contactsContainer(double w,double h){
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    CategoryProviderMessenger categoryProvider = Provider.of<CategoryProviderMessenger>(context);
    return  !showRequests?
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  fontSizeProvider.fontSizeMultiplier<=1?330:330 * fontSizeProvider.fontSizeMultiplier,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    textRubik('Messages',textColor,w500, size28*fontSizeProvider.fontSizeMultiplier),
                    GestureDetector(
                      onTap: (){
                        getMyFollowingsRefresh();
                      },
                      child: Icon(Icons.refresh,color: textColor,size:size15 * fontSizeProvider.fontSizeMultiplier,),
                    )
                  ],
                ),
                GestureDetector(
                    onTap:(){
                      getRequestsReceived();
                      setState((){
                        showRequests = true;
                      });
                    },
                    child: textRubik('Requests',textColor,w500, size18 * fontSizeProvider.fontSizeMultiplier)),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Stack(
            children: [
              Container(
                  width: fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
                  height: h*0.74,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(8),),
                  child:

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream:selectedCategory==''?
                      FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                          .snapshots():
                      FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                          .where('roll', isEqualTo: selectedCategory)
                          .snapshots(),

                      builder: (context, snapShot) {
                        if (snapShot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapShot.hasError) {
                          return Center(
                            child: textRoboto('Error loading messages', textColor, w400, size16 * fontSizeProvider.fontSizeMultiplier),
                          );
                        } else {

                          try{
                            List docs = snapShot.data!.docs;

// Function to parse date and time strings into DateTime
                            ContactSearchProvider contactSearchProvider = Provider.of<ContactSearchProvider>(context);
                            if(contactSearchProvider.searchText!=''){

                              docs = docs
                                  .where((doc) =>
                              (doc['firstName']+doc['lastName'] as String).toLowerCase().contains(contactSearchProvider.searchText)
                                  ||
                                  (doc['roll'] as String).toLowerCase().contains(contactSearchProvider.searchText)
                              )
                                  .toList();
                            }
                            return ListView.builder(itemBuilder: (context,index){
                              final data = docs[index].data();
                              try{
                                return GestureDetector(
                                  onSecondaryTapDown:myFollowing.contains(data['uid'])? (v)async{
                                    showDialog(context: context, builder: (context){
                                      return Dialog(
                                        backgroundColor: white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        child:Container(
                                          width: 300,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: white,
                                            borderRadius: BorderRadius.circular(12)
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              textRubik('Remove', selectedCategoryColor, w500, size20),
                                              SizedBox(height: 35,),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap:(){
                                                      Navigator.pop(context);
                                                    },
                                                    child: textRubik('Cancel', textColor, w400, size15),
                                                  ),
                                                  SizedBox(
                                                    width: 40,
                                                  ),
                                                  GestureDetector(
                                                    onTap:()async{
                                                      try{
                                                        DocumentSnapshot mySnap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).get();
                                                        DocumentSnapshot user2Snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(data['uid']).get();

                                                        List<String> myFollowing3 =  List.from(await mySnap['myFollowings']) ;
                                                        List<String> user2Following =   List.from(await user2Snap['myFollowings']) ;

                                                        if(myFollowing3.contains(data['uid'])){
                                                          myFollowing3.remove(data['uid']);
                                                        }
                                                        if(user2Following.contains(FirebaseAuth.instance.currentUser!.uid)){
                                                          user2Following.remove(FirebaseAuth.instance.currentUser!.uid);
                                                        }
                                                         await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).update(
                                                            {
                                                              'myFollowings':myFollowing3
                                                            });
                                                        await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(data['uid']).update(
                                                            {
                                                               'myFollowings':user2Following
                                                            }).then((value) {
                                                              Fluttertoast.showToast(msg: 'Removed Successfully!');
                                                              setState(() {
                                                                followEachOther=false;
                                                              });
                                                              getMyFollowingsRefresh();
                                                              Navigator.pop(context);
                                                        });
                                                      }
                                                      catch(e){
                                                        Fluttertoast.showToast(msg: 'Cannot remove right now!');
                                                        Navigator.pop(context);
                                                        print(e.toString());
                                                      }
                                                    },
                                                    child: textRubik('Confirm', Colors.red, w400, size15),
                                                  )
                                                ],
                                                  // SizedBox(width: 6,),
                                                  // data['isOnline'] ?? false ? Container(
                                                  //   width: 10,
                                                  //   height: 10,
                                                  //   decoration: BoxDecoration(
                                                  //     shape: BoxShape.circle,
                                                  //     color: Colors.green,
                                                  //   ),
                                                  // ) : Container()
                                              )
                                            ],
                                          ),
                                        )
                                      );
                                    });
                                  }:(v){},
                                  onTap:
                                  myFollowing.contains(data['uid'])?
                                  () async {
                                    try {
                                      user2_Uid_ForSetState = await data['uid'];

                                      DocumentReference chatRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Chats').doc(generateChatId(FirebaseAuth.instance.currentUser!.uid,await data['uid']));

                                      await  chatRef.set({

                                        'user1_Uid':FirebaseAuth.instance.currentUser!.uid,
                                        'user2_Uid':user2_Uid_ForSetState

                                      }).then((value) async{
                                        await chatRef.update({
                                          'docId':chatRef.id,
                                        });
                                        await chatRef.collection('Messages');
                                      }).then((value) async {
                                        setState(() {
                                          chat_DocId = chatRef.id;
                                          user1_Uid = FirebaseAuth.instance.currentUser!.uid;
                                          user2_Uid = user2_Uid_ForSetState;
                                          globalchatDocId = chat_DocId;
                                          globalchatReceiverUid = user2_Uid_ForSetState;
                                          globalchatReceiverUsername = capitalizeFirstLetter( data['firstName'])+" "+capitalizeFirstLetter( data['lastName']);
                                          globalChatReceiverProfileImage = data['imageUrl'];
                                          followEachOther = true;
                                        });
                                        DocumentReference ref = FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(user2_Uid_ForSetState);
                                        DocumentSnapshot unreadMessagesCheckSnap = await ref.get();
                                        if(unreadMessagesCheckSnap.exists){
                                          try{
                                            String exists = await unreadMessagesCheckSnap[FirebaseAuth.instance.currentUser!.uid];
                                          }
                                          catch(e){
                                            await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(user2_Uid_ForSetState).update({
                                              FirebaseAuth.instance.currentUser!.uid:'0'
                                            });
                                          }
                                        }

                                        await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update(
                                            {
                                              data['uid']:'0'
                                            });
                                        //   UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context,listen: false);
                                        //
                                        // // unreadMessagesDashboardProvider.resetIndexToZeroUnread(index, data['uid']);
                                        //   unreadMessagesDashboardProvider.reset();
                                        //   await unreadMessagesDashboardProvider.getAllPeopleUnreadMessages(allUsersUids);

                                      });

                                    } catch (e) {
                                      print(e.toString());
                                      Fluttertoast.showToast(
                                          msg: 'Cannot contact right now!');
                                    }
                                  }:(){
                                    setState(() {
                                      followEachOther = false;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10),
                                    width:  fontSizeProvider.fontSizeMultiplier<=1?330:330 * fontSizeProvider.fontSizeMultiplier,
                                    height:fontSizeProvider.fontSizeMultiplier<=1?70:70 * fontSizeProvider.fontSizeMultiplier ,
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
                                                    width: 40  * fontSizeProvider.fontSizeMultiplier ,
                                                    height: 40 * fontSizeProvider.fontSizeMultiplier,
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
                                                    width: 10  * fontSizeProvider.fontSizeMultiplier ,
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
                                                          size16 * fontSizeProvider.fontSizeMultiplier),
                                                      SizedBox(
                                                        height: 1.5,
                                                      ),
                                                      textRoboto(data['roll'],
                                                          textColor, w400, size14  * fontSizeProvider.fontSizeMultiplier )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Consumer<UnreadMessagesDashboardProvider>(
                                                    builder: (context, unreadMessagesDashboardProvider, _) {
                                                      // Check if uid_unread is not empty and index is valid
                                                      if (unreadMessagesDashboardProvider.uid_unread.isNotEmpty && index < unreadMessagesDashboardProvider.uid_unread.length) {
                                                        // Access uid_unread with null-aware operator and handle missing data
                                                        String unreadCount = unreadMessagesDashboardProvider.uid_unread[index][data['uid'] ?? ''] ?? '0';

                                                        return
                                                          myFollowing.contains(data['uid'])?
                                                          textRubik(unreadCount != '0' ? unreadCount : '', textColor, w500, size11 * fontSizeProvider.fontSizeMultiplier):
                                                          data['requestList'].contains(FirebaseAuth.instance.currentUser!.uid)?
                                                          textRubik('Requested', textColor, w500, size11  * fontSizeProvider.fontSizeMultiplier ):
                                                          GestureDetector(
                                                              onTap: ()async{
                                                                try{
                                                                  DocumentSnapshot requestSnap =  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(data['uid']).get();
                                                                  List<String> requestList =  List.from(await requestSnap['requestList']) ;


                                                                  requestList.add(FirebaseAuth.instance.currentUser!.uid);
                                                                  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(data['uid']).update({
                                                                    'requestList':FieldValue.arrayUnion(requestList)
                                                                  }).then((value) {
                                                                    Fluttertoast.showToast(msg: 'Request Sent');
                                                                  });
                                                                }
                                                                catch(e){
                                                                  print("hey $e" );
                                                                }
                                                              },
                                                              child: textRubik('+ Add', selectedCategoryColor, w500, size11  * fontSizeProvider.fontSizeMultiplier ));
                                                      } else {
                                                        // Handle empty or invalid data
                                                        return SizedBox(); // or any placeholder widget
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(width: 6,),
                                                  data['isOnline'] ?? false ? Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.green,
                                                    ),
                                                  ) : Container()
                                                ],
                                              )
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
                              }
                              catch(e){
                                print(e.toString());
                              }
                            },itemCount: docs.length,)  ;


                          }
                          catch(e){
                            print(e.toString());
                            return Center(child: textRubik('Change the Category!',blue,w400,size11 * fontSizeProvider.fontSizeMultiplier ),);
                          }


                        }})
              ),
              Positioned(child:        Container(
                width:  fontSizeProvider.fontSizeMultiplier<=1?330:330 * fontSizeProvider.fontSizeMultiplier ,
                height:   fontSizeProvider.fontSizeMultiplier <=1?70:70 * fontSizeProvider.fontSizeMultiplier ,
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10)
                ),                child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                width: fontSizeProvider.fontSizeMultiplier <=1?310:310 * fontSizeProvider.fontSizeMultiplier ,
                height:  fontSizeProvider.fontSizeMultiplier <=1?40:40 * fontSizeProvider.fontSizeMultiplier ,
                decoration: BoxDecoration(
                    color: offWhite,
                    borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10 * fontSizeProvider.fontSizeMultiplier),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Flexible(
                      child: Consumer<ContactSearchProvider>(builder: (context,contactSearchProvider,_){
                        return TextFormField(
                          controller: searchFieldController,
                          onChanged: (v){
                            contactSearchProvider.update(v);
                          },
                          style:  GoogleFonts.roboto(
                            textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14 * fontSizeProvider.fontSizeMultiplier),
                          ),
                          cursorColor: textColor,
                          decoration: InputDecoration.collapsed(hintText: 'Search Name or Role',
                            hintStyle:  GoogleFonts.roboto(
                              textStyle: TextStyle(color: textColorLight, letterSpacing: .5,fontWeight: w400,fontSize: size14 * fontSizeProvider.fontSizeMultiplier),
                            ),
                          ),
                        );
                      },),

                    ),
                  ],

                ),
              ),
              ),bottom:0)
            ],
          ),
        ],
      ): Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  textRubik('Requests',textColor,w500, size28*fontSizeProvider.fontSizeMultiplier),
                  GestureDetector(
                    onTap: (){
                      getRequestsReceivedRefresh();
                    },
                    child: Icon(Icons.refresh,color: textColor,size:size15 * fontSizeProvider.fontSizeMultiplier,),
                  )
                ],
              ),
              GestureDetector(
                  onTap:(){
                    getRequestsReceived();
                    setState((){
                      showRequests = false;
                    });
                  },
                  child: textRubik('Messages',textColor,w500, size18 * fontSizeProvider.fontSizeMultiplier)),
            ],
          ),
        ),
        SizedBox(height: 15,),
        Stack(
          children: [
            Container(
                width:  fontSizeProvider.fontSizeMultiplier<=1?330:330 * fontSizeProvider.fontSizeMultiplier,
                height: h*0.74,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),),
                child:

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream:selectedCategory==''?
                    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                        .snapshots():
                    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                        .where('roll', isEqualTo: selectedCategory)
                        .snapshots(),

                    builder: (context, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapShot.hasError) {
                        return Center(
                          child: textRoboto('Error loading messages', textColor, w400, size16 * fontSizeProvider.fontSizeMultiplier),
                        );
                      } else {

                        try{
                          List docs = snapShot.data!.docs;

// Function to parse date and time strings into DateTime
                          ContactSearchProvider contactSearchProvider = Provider.of<ContactSearchProvider>(context);
                          if(contactSearchProvider.searchText!=''){

                            docs = docs
                                .where((doc) =>
                            (doc['firstName']+doc['lastName'] as String).toLowerCase().contains(contactSearchProvider.searchText)
                                ||
                                (doc['roll'] as String).toLowerCase().contains(contactSearchProvider.searchText)
                            )
                                .toList();
                          }
                          return ListView.builder(itemBuilder: (context,index){
                            final data = docs[index].data();
                            try{
                              return requestsReceived.contains(data['uid'])?
                              GestureDetector(

                                // onTap:
                                // myFollowing.contains(data['uid'])?
                                //     () async {
                                //   try {
                                //     user2_Uid_ForSetState = await data['uid'];
                                //
                                //     DocumentReference chatRef = await FirebaseFirestore.instance.collection('Chats').doc(generateChatId(FirebaseAuth.instance.currentUser!.uid,await data['uid']));
                                //
                                //     await  chatRef.set({
                                //
                                //       'user1_Uid':FirebaseAuth.instance.currentUser!.uid,
                                //       'user2_Uid':user2_Uid_ForSetState
                                //
                                //     }).then((value) async{
                                //       await chatRef.update({
                                //         'docId':chatRef.id,
                                //       });
                                //       await chatRef.collection('Messages');
                                //     }).then((value) async {
                                //       setState(() {
                                //         chat_DocId = chatRef.id;
                                //         user1_Uid = FirebaseAuth.instance.currentUser!.uid;
                                //         user2_Uid = user2_Uid_ForSetState;
                                //         globalchatDocId = chat_DocId;
                                //         globalchatReceiverUid = user2_Uid_ForSetState;
                                //         globalchatReceiverUsername = capitalizeFirstLetter( data['firstName'])+" "+capitalizeFirstLetter( data['lastName']);
                                //         globalChatReceiverProfileImage = data['imageUrl'];
                                //         followEachOther = true;
                                //       });
                                //       DocumentReference ref = FirebaseFirestore.instance.collection('Users').doc(user2_Uid_ForSetState);
                                //       DocumentSnapshot unreadMessagesCheckSnap = await ref.get();
                                //       if(unreadMessagesCheckSnap.exists){
                                //         try{
                                //           String exists = await unreadMessagesCheckSnap[FirebaseAuth.instance.currentUser!.uid];
                                //         }
                                //         catch(e){
                                //           await FirebaseFirestore.instance.collection('Users').doc(user2_Uid_ForSetState).update({
                                //             FirebaseAuth.instance.currentUser!.uid:'0'
                                //           });
                                //         }
                                //       }
                                //
                                //       await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update(
                                //           {
                                //             data['uid']:'0'
                                //           });
                                //       //   UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context,listen: false);
                                //       //
                                //       // // unreadMessagesDashboardProvider.resetIndexToZeroUnread(index, data['uid']);
                                //       //   unreadMessagesDashboardProvider.reset();
                                //       //   await unreadMessagesDashboardProvider.getAllPeopleUnreadMessages(allUsersUids);
                                //
                                //     });
                                //
                                //   } catch (e) {
                                //     print(e.toString());
                                //     Fluttertoast.showToast(
                                //         msg: 'Cannot contact right now!');
                                //   }
                                // }:(){
                                //   setState(() {
                                //     followEachOther = false;
                                //   });
                                // },
                                child: Container(
                                  margin: EdgeInsets.only(top: 10),
                                  width:  fontSizeProvider.fontSizeMultiplier<=1?330:330 * fontSizeProvider.fontSizeMultiplier,
                                  height: fontSizeProvider.fontSizeMultiplier<=1?70:70 * fontSizeProvider.fontSizeMultiplier,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 14 ),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40 * fontSizeProvider.fontSizeMultiplier,
                                                  height: 40 * fontSizeProvider.fontSizeMultiplier,
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
                                                  width: 10 * fontSizeProvider.fontSizeMultiplier,
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
                                                        size16 * fontSizeProvider.fontSizeMultiplier),
                                                    SizedBox(
                                                      height: 1.5,
                                                    ),
                                                    textRoboto(data['roll'],
                                                        textColor, w400, size14 * fontSizeProvider.fontSizeMultiplier)
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Consumer<UnreadMessagesDashboardProvider>(
                                              builder: (context, unreadMessagesDashboardProvider, _) {
                                                // Check if uid_unread is not empty and index is valid
                                                if (unreadMessagesDashboardProvider.uid_unread.isNotEmpty && index < unreadMessagesDashboardProvider.uid_unread.length) {
                                                  // Access uid_unread with null-aware operator and handle missing data
                                                  String unreadCount = unreadMessagesDashboardProvider.uid_unread[index][data['uid'] ?? ''] ?? '0';

                                                  return
                                                    GestureDetector(
                                                        onTap: ()async{
                                                          try{
                                                            DocumentSnapshot myFollowingSnap =  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).get();
                                                            DocumentSnapshot user2FollowingSnap =  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(data['uid']).get();

                                                            List<String> myFollowing3 =  List.from(await myFollowingSnap['myFollowings']) ;
                                                            List<String> user2Following =   List.from(await user2FollowingSnap['myFollowings']) ;

                                                            // next person request list .add our uid
                                                            List<String> myRequests =  List.from(await myFollowingSnap['requestList']) ;
                                                            List<String> user2Requests =  List.from(await user2FollowingSnap['requestList']) ;

                                                            if(myRequests.contains(data['uid'])){
                                                              myRequests.remove(data['uid']);

                                                            }
                                                            if(user2Requests.contains(FirebaseAuth.instance.currentUser!.uid)){
                                                              user2Requests.remove(FirebaseAuth.instance.currentUser!.uid);
                                                            }


                                                            if(!user2Following.contains(FirebaseAuth.instance.currentUser!.uid)) {
                                                              user2Following.add(FirebaseAuth.instance.currentUser!.uid);

                                                            }
                                                            if(!myFollowing3.contains(data['uid'])) {
                                                              myFollowing3.add(data['uid']);
                                                            }

                                                            await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(data['uid']).update({
                                                              'myFollowings':FieldValue.arrayUnion(user2Following),
                                                              'requestList':FieldValue.arrayUnion(user2Requests)
                                                            }).then((value)async {
                                                              await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).update({
                                                                'myFollowings':FieldValue.arrayUnion(myFollowing3),
                                                                'requestList':myRequests
                                                              });

                                                              getRequestsReceivedRefresh();
                                                              // getMyFollowings();
                                                              Fluttertoast.showToast(msg: 'Request Accepted!');
                                                            });
                                                          }
                                                          catch(e){
                                                            print("hey $e" );
                                                          }
                                                        },
                                                        child: textRubik('Accept', selectedCategoryColor, w500, size11 * fontSizeProvider.fontSizeMultiplier));
                                                } else {
                                                  // Handle empty or invalid data
                                                  return SizedBox(); // or any placeholder widget
                                                }
                                              },
                                            )
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
                              )
                                  :Container();
                            }
                            catch(e){
                              print(e.toString());
                            }
                          },itemCount: docs.length,)  ;


                        }
                        catch(e){
                          print(e.toString());
                          return Center(child: textRubik('Change the Category!',blue,w400,size11),);
                        }


                      }})
            ),
            Positioned(child:        Container(
              width: fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
              height: fontSizeProvider.fontSizeMultiplier<=1?70:70 * fontSizeProvider.fontSizeMultiplier,
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(10)
              ),                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              width: fontSizeProvider.fontSizeMultiplier<=1? 310:310 * fontSizeProvider.fontSizeMultiplier,
              height:   fontSizeProvider.fontSizeMultiplier<=1?40:40 * fontSizeProvider.fontSizeMultiplier,
              decoration: BoxDecoration(
                  color: offWhite,
                  borderRadius: BorderRadius.circular(10)
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10 * fontSizeProvider.fontSizeMultiplier),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Flexible(
                    child: Consumer<ContactSearchProvider>(builder: (context,contactSearchProvider,_){
                      return TextFormField(
                        controller: searchFieldController,
                        onChanged: (v){
                          contactSearchProvider.update(v);
                        },
                        style:  GoogleFonts.roboto(
                          textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14),
                        ),
                        cursorColor: textColor,
                        decoration: InputDecoration.collapsed(hintText: 'Search Name or Roll',
                          hintStyle:  GoogleFonts.roboto(
                            textStyle: TextStyle(color: textColorLight, letterSpacing: .5,fontWeight: w400,fontSize: size14),
                          ),
                        ),
                      );
                    },),

                  ),
                ],

              ),
            ),
            ),bottom:0)
          ],
        ),
      ],
    );
  }

  bool isLoading2=false;


  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input; // Return an empty string if the input is empty
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  Color color1 = textColor;
  Color color2 = pageBackgroundColor;
  Color color3 = white;
  Color color4 = selectedCategoryColor;
  Color color5 = textColor;
  Widget linkLogRow(double w){
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    return
      Padding(
        padding: EdgeInsets.only(left: w*0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [

            // textRubik("Messages", textColor, w500, size28),

            SizedBox(width: 1,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/contrassIcon.png',width: 25,height: 25,),
                SizedBox(width: 10,),
                GestureDetector(
                    onTap: (){

                      if(textColor == color1){
                        setState(() {
                          textColor=Colors.grey[300]!;
                          pageBackgroundColor=Colors.black87;
                          white = Colors.black.withOpacity(0.8);
                          selectedCategoryColor = selectedCategoryColor.withOpacity(0.8);
                        });
                      }
                      else{
                        setState(() {
                          textColor=color1;
                          pageBackgroundColor=color2;
                          white = color3;
                          selectedCategoryColor = color4;
                        });
                      }
                    },
                    child: textRoboto('Increase contrast', textColor, w400, size14*fontSizeProvider.fontSizeMultiplier)),
                SizedBox(width: 15,),
                Container(
                  width: 1,
                  height: size14,
                  color: dottedDividerColor,
                ),
                SizedBox(width: 15,),
                Image.asset('assets/fontIcon.png',width: 20,height:20,),
                SizedBox(width: 10,),
                textRoboto('Font size',textColor, w400, size14),
                SizedBox(width: 10,),
                Consumer<FontSizeProvider>(builder: (context,fontSizeProvider,_){
                  return   Slider(
                    min:fontSizeProvider. minMultiplier,
                    max: fontSizeProvider.maxMultiplier,
                    value: fontSizeProvider.fontSizeMultiplier,
                    onChanged: (value) {
                      fontSizeProvider.update(value);
                    },
                    thumbColor: textColor,
                    activeColor: textColor,
                    secondaryActiveColor: textColor,

                    inactiveColor: lightestGrey,
                  );
                })

              ],
            )
          ],
        ),
      );
  }
  Widget linkLogRowMobile(double w){
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    return
      Padding(
        padding: EdgeInsets.only(left: w*0.05),
        child: SingleChildScrollView(
          scrollDirection:Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [

              // textRubik("Messages", textColor, w500, size28),

              SizedBox(width: 10,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/contrassIcon.png',width: 25,height: 25,),
                  SizedBox(width: 10,),
                  GestureDetector(
                      onTap: (){

                        if(textColor == color1){
                          setState(() {
                            textColor=Colors.grey[300]!;
                            pageBackgroundColor=Colors.black87;
                            white = Colors.black.withOpacity(0.8);
                            selectedCategoryColor = selectedCategoryColor.withOpacity(0.8);
                          });
                        }
                        else{
                          setState(() {
                            textColor=color1;
                            pageBackgroundColor=color2;
                            white = color3;
                            selectedCategoryColor = color4;
                          });
                        }
                      },
                      child: textRoboto('Increase contrast', textColor, w400, size14*fontSizeProvider.fontSizeMultiplier)),
                  SizedBox(width: 15,),
                  Container(
                    width: 1,
                    height: size14,
                    color: dottedDividerColor,
                  ),
                  SizedBox(width: 15,),
                  Image.asset('assets/fontIcon.png',width: 20,height:20,),
                  SizedBox(width: 10,),
                  textRoboto('Font size',textColor, w400, size14),
                  SizedBox(width: 10,),
                  Consumer<FontSizeProvider>(builder: (context,fontSizeProvider,_){
                    return   Slider(
                      min:fontSizeProvider. minMultiplier,
                      max: fontSizeProvider.maxMultiplier,
                      value: fontSizeProvider.fontSizeMultiplier,
                      onChanged: (value) {
                        fontSizeProvider.update(value);
                      },
                      thumbColor: textColor,
                      activeColor: textColor,
                      secondaryActiveColor: textColor,

                      inactiveColor: lightestGrey,
                    );
                  })

                ],
              )
            ],
          ),
        ),
      );
  }


  Widget appBar(double w,String username, String roll,String _imageUrl){
    SearchProvider searchProvider = Provider.of<SearchProvider>(context,listen: false);
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: false);

    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap:()async{
                try{
                  await updateMyOnlineStatus(false).then((value) {
                    Navigator.pop(context);
                  });
                }
                catch(e){
                  Navigator.pop(context);
                  print(e.toString());
                }
                },
                child: Icon(Icons.arrow_back,color: purple,size: 22,)),
            SizedBox(width: 13 * fontSizeProvider.fontSizeMultiplier,),
            Image.asset(
              'assets/logoText.png',
              width: 100*2 * fontSizeProvider.fontSizeMultiplier,
            ),
            SizedBox(width: 50 * fontSizeProvider.fontSizeMultiplier,),
            Container(
              width: w*0.4,
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
                  Image.asset('assets/searchIcon.png',width: 20,height: 20,),
                  SizedBox(width: 8,),
                  Flexible(
                    child: TextFormField(
                      controller: searchUrlController,
                      style:  GoogleFonts.roboto(
                        textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14),
                      ),
                      onChanged: (v){
                        searchProvider.update(v);
                      },
                      cursorColor: textColor,
                      decoration: InputDecoration.collapsed(hintText: 'Search keywords, URLs, links or meta descriptions',
                        hintStyle:  GoogleFonts.roboto(
                          textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14),
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
            SizedBox(width: w*0.006,),
            InkWell(
              onTap:()async{
                await _selectAndDisplayImage().then((value)async {

                  if(_imageFileDP!=null){
                    await _uploadImageDP().then((value) async{
                      await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update(
                          {

                            'imageUrl':imageUrlDP.isNotEmpty?imageUrlDP:'https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/profileImagePlaceHolder.png?alt=media&token=9d64cc25-ec5e-4360-9bd4-0c0663c2f143'
                          }).then((value) {
                        setState(() {
                          _imageUrl=imageUrlDP;
                        });
                      });

                    });
                  }

                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrlDP.isNotEmpty?imageUrlDP:_imageUrl,width: 42 * fontSizeProvider.fontSizeMultiplier,height: 42 * fontSizeProvider.fontSizeMultiplier,fit: BoxFit.cover,),
              ),
            ),
            SizedBox(width: w*0.0055,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                textRoboto(username,textColor,w500,size16 * fontSizeProvider.fontSizeMultiplier),
                SizedBox(height: 4,),
                textRubik(roll,textColor, w400,size10 * fontSizeProvider.fontSizeMultiplier),
              ],
            ),
            SizedBox(width: w*0.005,),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: lightGrey, size: 20 * fontSizeProvider.fontSizeMultiplier),
              onSelected: (value) async{
                if (value == 'logout') {
                  // Perform logout action here
                  try{
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.pushReplacement(context,CupertinoPageRoute(builder: (context)=>EmployeeLogin()));
                    });
                  }
                  catch(e){
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
                        textRoboto('Logout',textColor, w500,size13 * fontSizeProvider.fontSizeMultiplier),
                      ],
                    ),
                  ),
                  // You can add more items if needed
                ];
              },
            ),
            SizedBox(width: w*0.005,),

          ],
        )
      ],
    );
  }
  Widget appBarMobile(double w,String username, String roll,String _imageUrl){
    SearchProvider searchProvider = Provider.of<SearchProvider>(context,listen: false);
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: false);

    return  SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap:()async{
                    try{
                          await updateMyOnlineStatus(false).then((value) {
                            Navigator.pop(context);
                          });
                    }
                    catch(e){
                      print(e.toString());
                    }
                  },
                  child: Icon(Icons.arrow_back,color: purple,size: 22,)),
              SizedBox(width: 13 * fontSizeProvider.fontSizeMultiplier,),
              Image.asset(
                'assets/logoText.png',
                width: 100*2 * fontSizeProvider.fontSizeMultiplier,
              ),
              SizedBox(width: w*0.03),
              Container(
                width: w*0.3,
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
                    Image.asset('assets/searchIcon.png',width: 20,height: 20,),
                    SizedBox(width: 8,),
                    Flexible(
                      child: TextFormField(
                        controller: searchUrlController,
                        style:  GoogleFonts.roboto(
                          textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14),
                        ),
                        onChanged: (v){
                          searchProvider.update(v);
                        },
                        cursorColor: textColor,
                        decoration: InputDecoration.collapsed(hintText: 'Search keywords, URLs, links or meta descriptions',
                          hintStyle:  GoogleFonts.roboto(
                            textStyle: TextStyle(color: textColor, letterSpacing: .5,fontWeight: w400,fontSize: size14),
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
              SizedBox(width: w*0.03,),
              InkWell(
                onTap:()async{
                  await _selectAndDisplayImage().then((value)async {

                    if(_imageFileDP!=null){
                      await _uploadImageDP().then((value) async{
                        await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).update(
                            {

                              'imageUrl':imageUrlDP.isNotEmpty?imageUrlDP:'https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/profileImagePlaceHolder.png?alt=media&token=9d64cc25-ec5e-4360-9bd4-0c0663c2f143'
                            }).then((value) {
                          setState(() {
                            _imageUrl=imageUrlDP;
                          });
                        });

                      });
                    }

                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imageUrlDP.isNotEmpty?imageUrlDP:_imageUrl,width: 42 * fontSizeProvider.fontSizeMultiplier,height: 42 * fontSizeProvider.fontSizeMultiplier,fit: BoxFit.cover,),
                ),
              ),
              SizedBox(width: w*0.0055,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  textRoboto(username,textColor,w500,size16 * fontSizeProvider.fontSizeMultiplier),
                  SizedBox(height: 4,),
                  textRubik(roll,textColor, w400,size10 * fontSizeProvider.fontSizeMultiplier),
                ],
              ),
              SizedBox(width: w*0.005,),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: lightGrey, size: 20 * fontSizeProvider.fontSizeMultiplier),
                onSelected: (value) async{
                  if (value == 'logout') {
                    // Perform logout action here
                    try{
                      await FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushReplacement(context,CupertinoPageRoute(builder: (context)=>EmployeeLogin()));
                      });
                    }
                    catch(e){
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
                          textRoboto('Logout',textColor, w500,size13 * fontSizeProvider.fontSizeMultiplier),
                        ],
                      ),
                    ),
                    // You can add more items if needed
                  ];
                },
              ),
              SizedBox(width: w*0.005,),

            ],
          )
        ],
      ),
    );
  }

  File? _imageFile;
  File? _imageFileDP;
  final picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  String categoryImageUrl="";
  String imageUrlDP="";
  bool isSelected=false;
  bool isSelectedDP=false;

  Future<void> _selectAndDisplayImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _imageFile = File(pickedFile.path);
    });
    // print(_imageFile);
  }
  Future<bool> _uploadImageDP() async {
    try{
      if (_imageFileDP == null) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Please select an image first.'),
        //   ),
        // );
        isSelectedDP=false;
        return isSelectedDP;
      }

      final fileName = _imageFileDP!.path.split('/').last;

      final ref =await _storage.ref().child('images/$fileName');

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFileDP!.path).readAsBytes();

        UploadTask uploadTask = ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/png'),
        );

        TaskSnapshot snapshot = await uploadTask;


        final imageUrl = await ref.getDownloadURL();


        setState(() {
          imageUrlDP=imageUrl;
          isSelectedDP=true;
        });

        return isSelectedDP;
      } else {
        await ref.putFile(_imageFileDP!);
      }

      final imageUrl = await ref.getDownloadURL();

      setState(() {
        imageUrlDP=imageUrl;
        isSelectedDP=true;
      });
      return isSelectedDP;
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }

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

      final fileName = _imageFile!.path.split('/').last;

      final ref =await _storage.ref().child('images/$fileName');

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFile!.path).readAsBytes();

        UploadTask uploadTask = ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/png'),
        );

        TaskSnapshot snapshot = await uploadTask;


        final imageUrl = await ref.getDownloadURL();


        setState(() {
          categoryImageUrl=imageUrl;
          isSelected=true;
        });

        return isSelected;
      } else {
        await ref.putFile(_imageFile!);
      }

      final imageUrl = await ref.getDownloadURL();

      setState(() {
        categoryImageUrl=imageUrl;
        isSelected=true;
      });
      return isSelected;
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }

  Widget addSubListDialog(){

    bool      isLoading2=false;
    final fKey = GlobalKey<FormState>();

    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
          width: 350,
          height: 200,
          child: isLoading2?Center(child: CircularProgressIndicator(color: Colors.green,),):Form(
            key: fKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                textRoboto('Add Sublist',textColor, w600,size18),

                SizedBox(height: 20),
                GestureDetector(
                  onTap:()async{
                    // await _selectAndDisplayImage();

                    try{
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile == null) return;
                      setState(() {
                        _imageFile = File(pickedFile.path);
                      });
                      // print('file selected');
                      // print(_imageFile);
                    }
                    catch(e){
                      print(e.toString());
                    }
                  },child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child:
                    _imageFile==null?
                    Image.asset('assets/profileImagePlaceHolder.png',fit: BoxFit.cover,width: 35,height: 35,):
                    Image.network(_imageFile!.path,fit: BoxFit.cover,width: 35,height: 35,)

                ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  validator: (v){
                    return v!.length<2?'Please enter a sublist name':null;
                  },
                  controller: sublistController,
                  decoration: InputDecoration(
                    labelText: 'Sublist Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.indigo, width: 2),borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.indigo, width: 2),borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async{

                    if(fKey.currentState!.validate()){
                      String subListName = sublistController.text.toString();
                      try{
                        setState(() {
                          isLoading2=true;
                        });
                        bool uploaded =  await  _uploadImage();

                        final DocumentReference docRef =
                        FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Categories').doc(subListName);
                        // Check if the document already exists
                        final DocumentSnapshot docSnapshot = await docRef.get();

                        if (docSnapshot.exists) {
                          // Document already exists, update the fields
                          await docRef.update({
                            'categoryName': subListName,
                            'categoryImage': uploaded
                                ? categoryImageUrl
                                : "https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/subListIcon.png?alt=media&token=76b450e4-4f50-45c7-a093-7ba5c8627e0b"
                          }).then((value) {
                            Navigator.pop(context);
                            setState((){
                              isLoading2=false;
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
                            setState((){
                              isLoading2=false;
                            });

                          });
                        }
                      }
                      catch(e){
                        Navigator.pop(context);
                        print(e.toString());
                        setState((){
                          isLoading2=false;
                        });
                      }
                    }
                    // Handle the button press (e.g., save the sublist)
                    // Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

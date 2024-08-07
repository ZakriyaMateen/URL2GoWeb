import 'dart:async';
import 'dart:io';
// import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url2goweb/Properties/Colors.dart';
import 'package:url2goweb/Properties/fontWeights.dart';
import 'package:url2goweb/Providers/ContactSearchProvider.dart';
import 'package:url2goweb/Providers/shareListProvider.dart';
import 'package:url2goweb/Providers/shareListProviderSublist.dart';
import 'package:url2goweb/Screens/Messenger.dart';
import 'package:url2goweb/Screens/recentLinksMainCategory.dart';
import 'package:url2goweb/Screens/recentLinksMainCategorySearch.dart';
import 'package:url2goweb/Screens/recentLinksSubCategory.dart';
import 'package:url2goweb/Screens/recentLinksSubCategorySearch.dart';
import 'package:url2goweb/Utils/text.dart';
import 'package:url2goweb/Utils/transitions.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MetaDataFetch/MetaData.dart';
import '../Properties/fontSizes.dart';
import '../Providers/CategoryProvider.dart';
import '../Providers/CategoryProviderMessenger.dart';
import '../Providers/DateProvider.dart';
import '../Providers/FontSizeProvider.dart';
import '../Providers/ShareOptionsProvider.dart';
import '../Providers/ShareOptionsProviderSublist.dart';
import '../Providers/ShowHideSublistProvider.dart';
import '../Providers/SublistNameEditProvider.dart';
import '../Providers/UnreadMessagesDashboardProvider.dart';
import '../Providers/recentLinksTabProvider.dart';
import '../Providers/searchProvider.dart';
import '../Utils/CalendarWidget.dart';
import '../Utils/PdfPrint.dart';
import '../Utils/TextHasUrlAndExtractedUrl.dart';
import '../Utils/shareDialogSublist.dart';
import 'AuthScreens/CorpLogin.dart';
import 'AuthScreens/EmployeeLogin.dart';
import 'AuthScreens/LoginScreen.dart';
import 'AuthScreens/LoginScreenUser.dart';
import 'DailyLinksContainerMainCategory.dart';
import 'dailyLinksContainer.dart';

class Dashboard2 extends StatefulWidget {
  const Dashboard2({Key? key}) : super(key: key);

  @override
  State<Dashboard2> createState() => _Dashboard2State();
}

class _Dashboard2State extends State<Dashboard2> with WidgetsBindingObserver{
  String roll = '';
  String rollDuplicate='';
  String rollDuplicate2='';
  String profileImageUrl = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  bool isLoading = true;
  String roll1 = '';
  String corporationEmail = '';
  String corporationName = '';
  Future<String> getUserCorpDetailsFromAllUsersCollection()async{
    String corpEmail = 'empty';
    try{
        DocumentSnapshot snap = await FirebaseFirestore.instance.collection('AllUsers').doc(FirebaseAuth.instance.currentUser!.uid).get();
        String corpEmail = await snap['corporationEmail'];
        corporationEmail = corpEmail;
        return corpEmail;
    }
    catch(e){
      print('getUserCorpDetailsFromAllUsersCollection ' +e.toString());
      return corpEmail;
    }
  }
  bool isAccepted = true;
  Future<void> getUserDetails() async {
    try {
       await getUserCorpDetailsFromAllUsersCollection().then((corpEmail)async {
         DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection(corpEmail).doc(corpEmail)
             .collection('Users')
             .doc(FirebaseAuth.instance.currentUser!.uid)
             .get();
         String _roll = await snapshot['roll'];
         String _firstName = await snapshot['firstName'];
         String _lastName = await snapshot['lastName'];
         String _profileImage = await snapshot['imageUrl'];
         String _email = await snapshot['email'];
         String _corporationName = await snapshot['corporationName'];
         bool   _isAccepted = await snapshot['isAccepted'];
         String _corporationEmail = await snapshot['corporationEmail'];
         if (_roll.isNotEmpty &&
             _firstName.isNotEmpty &&
             _lastName.isNotEmpty &&
             _profileImage.isNotEmpty &&
             _email.isNotEmpty) {
           setState(() {
             isAccepted = _isAccepted;
             firstName = _firstName;
             lastName = _lastName;
             profileImageUrl = _profileImage;
             email = _email;
             roll = _roll;
             rollDuplicate = _roll;
             rollDuplicate2 = _roll;
             roll1 = _roll;
             corporationEmail = _corporationEmail;
             corporationName = _corporationName;
           });
         }
         // print(profileImageUrl);
         
         setState(() {
           isLoading = false;
         });
      });


    } catch (e) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>EmployeeLogin()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textCenter('Please sign in again!', white, w400, size13),));
      Fluttertoast.showToast(msg: 'Please Sign in again');
      print('getUserDetails'+e.toString());
    }
  }
  Future<void> updateMyOnlineStatus(bool status)async{
    try{
      DocumentReference onlineRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid);
      await onlineRef.update({
        'isOnline':status
      });
    }
    catch(e){
      print(e.toString());
    }
  }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // online
  //     updateMyOnlineStatus(true);
  //   } else if (state == AppLifecycleState.paused ||
  //       state == AppLifecycleState.inactive) {
  //     // offline
  //     updateMyOnlineStatus(false);
  //   }
  // }
  Future<void> getUserDetails_X_getRequestsReceived_X_getMyFollowings_X_getAllUserIds()async{
    try{

        await getUserDetails().then((value) async{
          await getAllUserIds().then((value) async{
            getMyFollowings();
            getRequestsReceived();
          });
        });
        // await updateMyOnlineStatus(true);


    }
    catch(e){
      print('getUserDetails_X_getRequestsReceived_X_getMyFollowings_X_getAllUserIds'+e.toString());
    }
  }
  late AppLifecycleState state;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails_X_getRequestsReceived_X_getMyFollowings_X_getAllUserIds();
    html.window.addEventListener('beforeunload', (event) async{
      // Custom code to handle browser/tab closing
      // You can add your logic here
      await updateMyOnlineStatus(false);
    });

  }

  @override
  void dispose() {
    super.dispose();
    // Remember to remove the event listener when the widget is disposed
    html.window.removeEventListener('beforeunload', (event) {});
    categoryNameEditController.dispose();
    messagesSearchController.dispose();
    sublistController.dispose();
    sublistNoteController.dispose();
    addRecentLinkNoteController.dispose();
  }
   String messageSearchText = '';
  String searchText = '';
  TextEditingController searchFieldController = TextEditingController();
  TextEditingController messagesSearchController = TextEditingController();
  TextEditingController sublistController = TextEditingController();
  TextEditingController sublistNoteController = TextEditingController();
  String mySublistDocId = '';
  bool same=true;
  bool same3=true;
  final TransformationController _transformationController = TransformationController();
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    ShareOptionsProviderSublist shareOptionsProviderSublist = Provider.of<ShareOptionsProviderSublist>(context);
    FontSizeProvider fontSizeProvider2 = Provider.of<FontSizeProvider>(context,listen: true);
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return 
      isAccepted?
      GestureDetector(
      onDoubleTap: () {
        setState(() {
          _scale = _scale == 1.0 ? 2.0 : 1.0; // Toggle between zoom in and zoom out
          _transformationController.value = Matrix4.diagonal3Values(_scale, _scale, 1.0);
        });
      },
      child: Scaffold(
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
                    w>800?appBar(w, "$firstName $lastName", roll, profileImageUrl):
                    appBarMobile(w, "$firstName $lastName", roll, profileImageUrl),
                    SizedBox(
                      height: 25,
                    ),
                    w>1100? linkLogRow(w):linkLogRowMobile(w),
                    SizedBox(
                      height: 15,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          shareOptionsProviderSublist.shareOption=='contact'?shareSublistContainer(w,h):
                          rootCategories(w, h),
                          SizedBox(
                            width: w * 0.005,
                          ),
                          // categoryRow(w, h),
                          // SizedBox(
                          //   width: w * 0.02,
                          // ),
                          recentLinksContainer(w, h),
                          SizedBox(
                            width: w * 0.04,
                          ),
                          mySublistDocId!=''?
                          dailyLinksContainer(w, h,context,corporationEmail,fontSizeProvider2):
                          // dailyLinksContainerMainCategory(w,h,context,roll,same), Original Line to uncomment if updated goes wrong
                          dailyLinksContainerMainCategory(w, h, context, roll, same,corporationEmail,fontSizeProvider2),
                          SizedBox(width: w * 0.04,),
                          messagesContainerUpdatedCurrentlyUsing(w, h),
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
      ),
    ):
      Scaffold(backgroundColor: white,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: white,
            actions: [
              TextButton(
                onPressed:()async{
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
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    textRoboto('Logout', textColor, w500, size16),
                    SizedBox(width:7),
                    Icon(Icons.logout,size: size17,)
                  ],
                ),
              )
            ],
          ),
          body:Center(
        child: textRoboto("Waiting for Admin's consent!", textColor, w500, size20),
      ));

  }
  String contactSearchText = '';

  List<String> allUsersUids = [];
  List<String> allPeopleUnreadMessagesList = [];
  List<Map<String,dynamic>> uid_unread = [];

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

       // getAllPeopleUnreadMessages();
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
    Timer.periodic(Duration(seconds: 30), (timer) async {
       unreadMessagesDashboardProvider.reset();
      await unreadMessagesDashboardProvider.getAllPeopleUnreadMessages(allUsersUids,corporationEmail);
    });
  }



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


  Future<List<String>> creatingChat(Map<String,dynamic> data,int index)async{
    try{
      String  user2_Uid_ForSetState = '';
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
        // setState(() {
        //   // chat_DocId = chatRef.id;
        //   // user1_Uid = FirebaseAuth.instance.currentUser!.uid;
        //   // user2_Uid = user2_Uid_ForSetState;
        // });
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
        // setState(() {
        //   uid_unread[index][data['uid']]='0';
        // });


      });
      return [chatRef.id,FirebaseAuth.instance.currentUser!.uid,user2_Uid_ForSetState];

    }
    catch(e){
      print(e.toString());
      return ['','',''];
    }
  }
  void processSelectedItems(List<Map<String, dynamic>> shareList,String sharingUrl) {
    bool anySelected = false;
    List<String> selectedUids = [];

    for (final item in shareList) {
      if (item['isSelected']) {
        anySelected = true;
        // print('selected');
        selectedUids.add(item['uid']);
      }
    }
    ShareListProvider shareListProvider = Provider.of<ShareListProvider>(context,listen: false);
    ShareOptionsProvider shareOptionsProvider = Provider.of<ShareOptionsProvider>(context,listen: false);
    if (anySelected) {
      forwardUrl(selectedUids,sharingUrl).then((value) {
        shareListProvider.reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Forwarded Successfully', white, w400, size14)));
      });
    }
    else{
      // shareOptionsProvider.reset();

    }

    // print(selectedUids);
  }
  void processSelectedItemsSublist(List<Map<String, dynamic>> shareList,String sharingUrl) {
    bool anySelected = false;
    List<String> selectedUids = [];

    for (final item in shareList) {
      if (item['isSelected']) {
        anySelected = true;
        // print('selected');
        selectedUids.add(item['uid']);
      }
    }
    ShareListProviderSublist shareListProvider = Provider.of<ShareListProviderSublist>(context,listen: false);
    if (anySelected) {
      forwardUrlSublist(selectedUids,sharingUrl).then((value) {
        shareListProvider.reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Forwarded Successfully', white, w400, size14)));
      });
    }
    else{
      // shareOptionsProvider.reset();

    }

    // print(selectedUids);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mma').format(dateTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM y').format(dateTime);
  }

  void sendMessage(String v,String user2Uid, String senderUid)async{
    String chatDocId = generateChatId(senderUid, user2Uid);
    // TextHasUrlAndExtractedUrl urlInfo = extractUrlInfo(v!.toString());
    String url = v;
    // print("Has URL: ${urlInfo.hasUrl}");
    // print("URL: ${urlInfo.url}");

    String text = v.toString();

    try{

      String metaData='Empty';


        try{
          UrlMetadata metadata = await fetchUrlMetadata(url.startsWith('https://')?url:'https://$url');
          metaData  =metadata.title==''?url:metadata.title;
        }
        catch(e){
          metaData='Empty';
        }

      DateTime now = DateTime.now();

      String formattedTime = formatTime(now);
      String formattedDate = formatDate(now);
      DocumentReference ref=  await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Chats').doc(chatDocId).collection('Messages').add(
          {
            'receiverUid':user2Uid,
            'senderUid':senderUid,
            // 'receiverUid':globalchatReceiverUid,
            // 'senderUid':globalchatReceiverUid,
            'time':formattedTime,
            'date':formattedDate,
            'timeStamp':DateTime.now(),
            'hasUrl':true,
            'metaData':metaData,
            'url':url,
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

      DocumentReference chatRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(user2Uid);
      DocumentSnapshot chatSnap = await chatRef.get();


      String unreadMessages = await chatSnap[FirebaseAuth.instance.currentUser!.uid];
      chatRef.update({
        FirebaseAuth.instance.currentUser!.uid : (int.parse(unreadMessages)+1).toString()
      });

    }
    catch(e){
      DocumentReference chatRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(user2Uid);
      DocumentSnapshot chatSnap = await chatRef.get();

      chatRef.update({
        FirebaseAuth.instance.currentUser!.uid :'1'
      });
      print(e.toString());
    }

  }

  Future<void> forwardUrl(List<String> selectedUids,String sharingUrl)async{
    try{
      ShareOptionsProvider shareOptionsProvider = Provider.of<ShareOptionsProvider>(context,listen: false);
    shareOptionsProvider.reset();
      for(String uid in selectedUids){
        sendMessage(sharingUrl, uid, FirebaseAuth.instance.currentUser!.uid);
      }
    }
    catch(e){
      print(e.toString());
    }
  }
  Future<void> forwardUrlSublist(List<String> selectedUids,String sharingUrl)async{
    try{
      ShareOptionsProviderSublist shareOptionsProvider = Provider.of<ShareOptionsProviderSublist>(context,listen: false);
    shareOptionsProvider.reset();
      for(String uid in selectedUids){
        sendMessage(sharingUrl, uid, FirebaseAuth.instance.currentUser!.uid);
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  Future<void> forwardSublist(List<String> selectedUids,String sharingUrl)async{
    try{
      // ShareOptionsProvider shareOptionsProvider = Provider.of<ShareOptionsProvider>(context,listen: false);
      // shareOptionsProvider.reset();
      for(String uid in selectedUids){
        sendMessage(sharingUrl, uid, FirebaseAuth.instance.currentUser!.uid);
      }
    }
    catch(e){
      print(e.toString());
    }
  }
  Widget messagesContainerForSharing(double w,double h){

    ShareListProvider shareListProvider = Provider.of<ShareListProvider>(context,listen: false);
    ShareOptionsProvider shareOptionsProvider = Provider.of<ShareOptionsProvider>(context,listen: false);
    CategoryProviderMessenger categoryProvider = Provider.of<CategoryProviderMessenger>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textRubik('Forward To ',textColor,w500, size18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  GestureDetector(
                      onTap:(){
                        shareOptionsProvider.reset();
                      },
                      child: textRubik('Cancel', textColor, w600,size17)),
                  SizedBox(width: 6,),

                  GestureDetector(
                      onTap:()async{
                        processSelectedItems(shareListProvider.shareList,shareListProvider.sharingUrl);
                      },
                      child: textRubik('Send', green, w600,size17)),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 15,),
        Stack(
          children: [
            Container(
                width: 330,
                height: h*0.74,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),),
                child:

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                    stream:    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                        .snapshots(),
                    builder: (context, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapShot.hasError) {
                        return Center(
                          child: textRoboto('Error loading messages', textColor, w400, size16),
                        );
                      } else {

                        List docs = snapShot.data!.docs;

// Function to parse date and time strings into DateTime
                        if(contactSearchText!=''){

                          docs = docs
                              .where((doc) =>
                          (doc['firstName']+doc['lastName'] as String).toLowerCase().contains(contactSearchText)
                              ||
                              (doc['roll'] as String).toLowerCase().contains(contactSearchText)
                          )
                              .toList();
                        }
                        return ListView.builder(itemBuilder: (context,index){
                          final data = docs[index].data();
                          shareListProvider.update({
                            'uid': data['uid'],
                            'isSelected':false
                          });
                          return Padding(
                            padding:EdgeInsets.only(bottom:index==docs.length-1?60:0),
                            child: InkWell(
                              onTap: () async {
                                try {

                                  shareListProvider.flipIsSelected(index);


                                } catch (e) {
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
                                          Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  // color:  shareListProvider.shareList[index]['isSelected']?textColor:Colors.orange,
                                                  border: Border.all(color: Colors.black,width: 1.5)
                                              ),
                                              padding: EdgeInsets.all(2),
                                              child:  Consumer<ShareListProvider>(builder:(context,shareListProviderr,_){
                                                return shareListProviderr.shareList[index]['isSelected']?Center(
                                                    child:Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                          color: btnBgColor,
                                                          shape: BoxShape.circle
                                                      ),
                                                    )
                                                ):Container();
                                              })
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
                            ),
                          );
                        },itemCount: docs.length,)  ;

                      }})
            ),

          ],
        ),
      ],
    );
        
  }
  List<String> myFollowing = [];
  List<String> requestsReceived = [];
  void getMyFollowings()async{
    try{
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
       List<String> myFollowings = List.from(await snap['myFollowings']) ;
      if(myFollowings.isNotEmpty){
          myFollowing = myFollowings;
      }


    }
    catch(e){
      print("getMyFollowings"+e.toString());
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
      }

    }
    catch(e){
      print("getMyFollowingsRefresh"+e.toString());
    }
  }

  Future<void> getRequestsReceived()async{
    try{
      DocumentSnapshot requestsReceivedSnap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
       requestsReceived = List.from(await requestsReceivedSnap['requestList']);

    }
    catch(e){
      print("getRequestsReveived"+ e.toString());
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
      print("getRequestsReceivedRefresh " + e.toString());
    }
  }

  bool showRequests = false;
  Widget messagesContainerUpdatedCurrentlyUsing(double w,double h){

    // UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context,listen: false);
    CategoryProviderMessenger categoryProvider = Provider.of<CategoryProviderMessenger>(context);
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return
      !showRequests?   Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    textRubik('Messages',textColor,w500, size28 * fontSizeProvider.fontSizeMultiplier),
                    SizedBox(width:7),
                    GestureDetector(
                      onTap: (){
                        getMyFollowingsRefresh();
                      },
                        child: Icon(Icons.refresh,color: textColor,size: size15 * fontSizeProvider.fontSizeMultiplier,)

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

                  stream:    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                          .snapshots(),
                      builder: (context, snapShot) {
                        if (snapShot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapShot.hasError) {
                          return Center(
                            child: textRoboto('Error loading messages', textColor, w400, size16),
                          );
                        } else {

                          List docs = snapShot.data!.docs;
                          if(docs.isEmpty){
                            return Center(child:textRubik('No Contacts Found!',textColor, w400,size10));
                          }
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
                            return InkWell(
                              onTap: () async {
                                try {
                                  await updateMyOnlineStatus(true).then((value) async{
                                    await creatingChat(data,index).then((value) async{
                                      // print(value[0]+' '+value[1]+' '+value[2]);
                                      String image = data['imageUrl'];
                                      String name = capitalizeFirstLetter(await data['firstName'])+" "+capitalizeFirstLetter(await data['lastName']);
                                      String roll = await data['roll'];
                                      String receiverId = value[2];
                                      String docId = value[0];
                                      UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context,listen: false);
                                      unreadMessagesDashboardProvider.reset();

                                      navigateWithTransition(context,
                                          Messenger(
                                            globalChatReceiverProfileImage: image,
                                            globalchatReceiverUsername: name,
                                            globalchatReceiverRoll:roll,
                                            globalchatDocId:docId,
                                            globalchatReceiverUid:receiverId,
                                            globalisRequestMessage: 'false',
                                            followEachother: myFollowing.contains(data['uid'])?true:false,
                                          ),
                                          TransitionType.slideRightToLeft);
                                    });


                                  });

                                } catch (e) {
                                  print(e.toString());
                                  Fluttertoast.showToast(
                                      msg: 'Cannot contact right now!');
                                }

                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                width: fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
                                height:fontSizeProvider.fontSizeMultiplier<=1?70: 70 * fontSizeProvider.fontSizeMultiplier,
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
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Consumer<UnreadMessagesDashboardProvider>(
                                                builder: (context, unreadMessagesDashboardProvider, _) {
                                                  // Check if uid_unread is not empty and index is valid
                                                  if (unreadMessagesDashboardProvider.uid_unread.isNotEmpty && index < unreadMessagesDashboardProvider.uid_unread.length) {
                                                    // Access uid_unread with null-aware operator and handle missing data
                                                    String unreadCount = unreadMessagesDashboardProvider.uid_unread[index][data['uid'] ?? ''] ?? '0';

                                                    return
                                                      myFollowing.contains(data['uid'])?
                                                      textRubik(unreadCount != '0' ? unreadCount : '', textColor, w500, size11):
                                                      data['requestList'].contains(FirebaseAuth.instance.currentUser!.uid)?
                                                      textRubik('Requested', textColor, w500, size11):
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
                                                          child: textRubik('+ Add', selectedCategoryColor, w500, size11));
                                                  } else {
                                                    // Handle empty or invalid data
                                                    return SizedBox(); // or afny placeholder widget
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

                                          // textRubik(unreadMessagesDashboardProvider.uid_unread[index][data['uid']??'']!='0'?unreadMessagesDashboardProvider.uid_unread[index][data['uid']]:'', textColor,w500,size11)

                                          // textRubik(uid_unread[index][data['uid']??'']!='0'?uid_unread[index][data['uid']]:'', textColor,w500,size11)
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
                          },itemCount: docs.length,)  ;




                        }})
              ),
              Positioned(child:        Container(
                width: 330,
                height: 70,
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10)
                ),                child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                width: 310,
                height: 40,
                decoration: BoxDecoration(
                    color: offWhite,
                    borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10),
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
                          decoration: InputDecoration.collapsed(hintText: 'Search Name or Role',
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
      ):
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    textRubik('Requests',textColor,w500, size28),
                    GestureDetector(
                        onTap:()async{
                          getRequestsReceivedRefresh();
                        },
                        child: Icon(Icons.refresh,color: textColor,size: size15,)),

                  ],
                ),
                GestureDetector(
                    onTap:(){
                      getMyFollowings();
                      setState((){
                        showRequests = false;
                      });
                    },
                    child: textRubik('Messages',textColor,w500, size18)),
                SizedBox(width:8),

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

                      stream:    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                          .snapshots(),
                      builder: (context, snapShot) {
                        if (snapShot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapShot.hasError) {
                          return Center(
                            child: textRoboto('Error loading messages', textColor, w400, size16),
                          );
                        } else {

                          List docs = snapShot.data!.docs;
                          if(docs.isEmpty){
                            return Center(child:textRubik('No Contacts Found!',textColor, w400,size10));
                          }
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
                            return requestsReceived.contains(data['uid'])? InkWell(

                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                width: fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier,
                                height: fontSizeProvider.fontSizeMultiplier<=1?70: 70 * fontSizeProvider.fontSizeMultiplier,
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
                                                width: 40*fontSizeProvider.fontSizeMultiplier,
                                                height: 40*fontSizeProvider.fontSizeMultiplier,
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
                                                      size16*fontSizeProvider.fontSizeMultiplier),
                                                  SizedBox(
                                                    height: 1.5,
                                                  ),
                                                  textRoboto(data['roll'],
                                                      textColor, w400, size14*fontSizeProvider.fontSizeMultiplier)
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
                                                      child: textRubik('Accept', selectedCategoryColor, w500, size11));
                                              } else {
                                                // Handle empty or invalid data
                                                return SizedBox(); // or any placeholder widget
                                              }
                                            },
                                          )

                                          // textRubik(unreadMessagesDashboardProvider.uid_unread[index][data['uid']??'']!='0'?unreadMessagesDashboardProvider.uid_unread[index][data['uid']]:'', textColor,w500,size11)

                                          // textRubik(uid_unread[index][data['uid']??'']!='0'?uid_unread[index][data['uid']]:'', textColor,w500,size11)
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
                            ):Container();
                          },itemCount: docs.length,)  ;




                        }})
              ),
              Positioned(child:        Container(
                width: 330,
                height: 70,
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10)
                ),                child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                width: 310,
                height: 40,
                decoration: BoxDecoration(
                    color: offWhite,
                    borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10),
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
      )
    ;
  }



  // Initialize with the current date


  bool isLoading2 = false;
  TextEditingController addRecentLinkNoteController = TextEditingController();
  Widget recentLinksContainer(double w, double h) {

    final categoryProvider = Provider.of<CategoryProvider>(context);
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final fKey = GlobalKey<FormState>();
    ShareOptionsProvider shareOptionsProvider = Provider.of<ShareOptionsProvider>(context,listen: true);

    TextEditingController addRecentLinkController = TextEditingController();
    return Stack(
      children: [
      Consumer<SearchProvider>(builder: (context,searchProvider,_){
        return   Container(
            width:  fontSizeProvider.fontSizeMultiplier<=1?330: 330 * fontSizeProvider.fontSizeMultiplier, height: h * 0.8,
            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(8),),

            child:

                shareOptionsProvider.shareOption=='contact'?
                messagesContainerForSharing(w, h):

            searchProvider.searchText==''?
              mySublistDocId=='' ?
            recentLinksMainCategory(w, h, roll, categoryProvider, fontSizeProvider,profileImageUrl, firstName, lastName,corporationEmail)
                :recentLinksSubCategory(w, h, roll, categoryProvider,fontSizeProvider, profileImageUrl, firstName, lastName,mySublistDocId,corporationEmail)

                :


            mySublistDocId!=''    ?
            recentLinksSubCategorySearch(w, h, roll, categoryProvider, profileImageUrl, firstName, lastName, mySublistDocId,searchText,context,corporationEmail):
            recentLinksMainCategorySearch(w, h, roll, categoryProvider,fontSizeProvider, profileImageUrl, firstName, lastName,searchText,context,corporationEmail)
        );
      }),
        // categoryProvider.title.isNotEmpty
     same3?   mySublistDocId!=''?
        Positioned(
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
                              height: 380,
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
                                      Column(
                                        children: [
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
                                                      .instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId);
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
                                                    'readBy': readBy,
                                                    'note':addRecentLinkNoteController.text.length>0?addRecentLinkNoteController.text.toString():'Empty'
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
                                                      addRecentLinkNoteController.clear();
                                                      addRecentLinkController.clear();
                                                    });
                                                    Navigator.pop(
                                                        context);
                                                  });
                                                } catch (e) {
                                                  setState(() {
                                                    isLoading2 = false;
                                                    addRecentLinkNoteController.clear();
                                                    addRecentLinkController.clear();
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
                                          SizedBox(height: 5,),
                                          TextFormField(
                                            controller:
                                            addRecentLinkNoteController,

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
                                                      .instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId);
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
                                                    'readBy': readBy,
                                                    'note':addRecentLinkNoteController.text.length>0?addRecentLinkNoteController.text.toString():'Empty'
                                                    // 'docId': '',  // No need to add this field initiallya
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
                                                      addRecentLinkNoteController.clear();
                                                      addRecentLinkController.clear();
                                                    });
                                                    Navigator.pop(
                                                        context);
                                                  });
                                                } catch (e) {
                                                  setState(() {
                                                    isLoading2 = false;
                                                    addRecentLinkNoteController.clear();
                                                    addRecentLinkController.clear();
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
                                                hintText: 'Add a Note (Optional)'),
                                          ),
                                        ],
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
                                              DateFormat('dd MMM yyyy');
                                              final DateFormat
                                              timeFormat =
                                              DateFormat('hh:mma');

                                              String formattedDate =
                                              dateFormat
                                                  .format(now);
                                              String formattedTime =
                                              timeFormat
                                                  .format(now);

                                              final CollectionReference
                                              recentLinksCollection =
                                              FirebaseFirestore
                                                  .instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId);

                                              List<String> readBy =
                                              [];
                                              // readBy.add(FirebaseAuth.instance.currentUser!.uid);
                                              DocumentReference
                                              newLinkDoc =
                                              await recentLinksCollection.add({
                                                'senderUid':
                                                FirebaseAuth.instance.currentUser!.uid,
                                                'url': url,
                                                'date': formattedDate,
                                                'time': formattedTime,
                                                'metaData': metaData,
                                                'readBy': readBy,
                                                'note':addRecentLinkNoteController.text.length>0?addRecentLinkNoteController.text.toString():'Empty'

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
                                                  addRecentLinkNoteController.clear();
                                                  addRecentLinkController.clear();
                                                });
                                                Navigator.pop(
                                                    context);
                                              });
                                            } catch (e) {
                                              setState(() {
                                                isLoading2 = false;
                                                addRecentLinkNoteController.clear();
                                                addRecentLinkController.clear();
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
                                                  w500, size14*fontSizeProvider.fontSizeMultiplier)
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
                width: fontSizeProvider.fontSizeMultiplier<=1?310:310*fontSizeProvider.fontSizeMultiplier,
                height: fontSizeProvider.fontSizeMultiplier<=1?40:40*fontSizeProvider.fontSizeMultiplier,
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
                      textRubik("+ Add new URL", white, w400, size14*fontSizeProvider.fontSizeMultiplier)
                    ],
                  ),
                ),
              ),
            ))
         :  Positioned(
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
                              height: 380,
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
                                      Column(
                                        children: [
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
                                                      .instance.collection(corporationEmail).doc(corporationEmail).collection(roll);
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
                                                    'readBy': readBy,
                                                    'note':addRecentLinkNoteController.text.isNotEmpty?addRecentLinkNoteController.text.toString():''

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
                                                      addRecentLinkNoteController.clear();
                                                      addRecentLinkController.clear();
                                                    });
                                                    Navigator.pop(
                                                        context);
                                                  });
                                                } catch (e) {
                                                  setState(() {
                                                    isLoading2 = false;
                                                    addRecentLinkNoteController.clear();
                                                    addRecentLinkController.clear();
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
                                          SizedBox(height: 5,),
                                          TextFormField(
                                            controller:
                                            addRecentLinkNoteController,

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
                                                      .instance.collection(corporationEmail).doc(corporationEmail).collection(roll);
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
                                                    'readBy': readBy,
                                                    'note':addRecentLinkNoteController.text.isNotEmpty?addRecentLinkNoteController.text.toString():''
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
                                                      addRecentLinkNoteController.clear();
                                                      addRecentLinkController.clear();
                                                    });
                                                    Navigator.pop(
                                                        context);
                                                  });
                                                } catch (e) {
                                                  setState(() {
                                                    isLoading2 = false;
                                                    addRecentLinkNoteController.clear();
                                                    addRecentLinkController.clear();
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
                                                hintText: 'Add a Note (Optional)'),
                                          ),
                                        ],
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
                                                  .instance.collection(corporationEmail).doc(corporationEmail).collection(roll);

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
                                                'readBy': readBy,
                                                'note':addRecentLinkNoteController.text.isNotEmpty?addRecentLinkNoteController.text.toString():''

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
                                                  addRecentLinkNoteController.clear();
                                                  addRecentLinkController.clear();
                                                });
                                                Navigator.pop(
                                                    context);
                                              });
                                            } catch (e) {
                                              setState(() {
                                                isLoading2 = false;
                                                addRecentLinkNoteController.clear();
                                                addRecentLinkController.clear();
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
                                                  w500, size14*fontSizeProvider.fontSizeMultiplier)
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
                width: fontSizeProvider.fontSizeMultiplier<=1?310:310*fontSizeProvider.fontSizeMultiplier,
                height: fontSizeProvider.fontSizeMultiplier<=1?40:40*fontSizeProvider.fontSizeMultiplier,
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
                      textRubik("+ Add new URL", white, w400, size14*fontSizeProvider.fontSizeMultiplier)
                    ],
                  ),
                ),
              ),
            )):
        Container()
      ],
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
      bool showCategoryRow=false;
      Widget rootCategories(double w, double h) {
        final fontSizeProvider = Provider.of<FontSizeProvider>(context);
        ShowHideSublistProvider showHideSublistProvider = Provider.of<ShowHideSublistProvider>(context,listen:false);
        return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 400,
              height: h * 0.6,
              padding: EdgeInsets.only(left: 20),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return roll1!=rootCategoriesList[index]['title']?
                  Container(
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
                            return Row(

                              children: [
                                InkWell(
                                  onTap: () async{
                                    DocumentSnapshot snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
                                    setState((){
                                      showCategoryRow=false;
                                      rollDuplicate = rootCategoriesList[index]['title'];
                                      rollDuplicate2 = rootCategoriesList[index]['title'];
                                      same = roll== rootCategoriesList[index]['title'];
                                      roll = rootCategoriesList[index]['title'];
                                      if(same){
                                        mySublistDocId = '';
                                      }
                                    });
                                    bool  same2 =  snap['roll']==rollDuplicate2;

                                    setState(() {
                                      same3 = same2;
                                    });


                                    categoryProvider.reset();
                                    },
                                  child: Container(
                                    width:150,
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
                                      size16*fontSizeProvider.fontSizeMultiplier,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10,),


                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ):
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
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
                                return Row(

                                  children: [
                                    InkWell(
                                      onTap: () async{
                                        DocumentSnapshot snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
                                        setState((){
                                          rollDuplicate = rootCategoriesList[index]['title'];
                                          rollDuplicate2 = rootCategoriesList[index]['title'];
                                          same = roll== rootCategoriesList[index]['title'];
                                          roll = rootCategoriesList[index]['title'];
                                          if(same){
                                            mySublistDocId = '';
                                          }
                                        });
                                        bool  same2 =  snap['roll']==rollDuplicate2;

                                        setState(() {
                                          same3 = same2;
                                        });

                                        categoryProvider.reset();
                                      },
                                      child: Container(
                                        width:150,
                                        child: textRoboto(
                                          rootCategoriesList[index]['title'],
                                          rootCategoriesList[index]['title']==roll
                                              ? selectedCategoryColor
                                              : textColor,
                                          w400,
                                          size16*fontSizeProvider.fontSizeMultiplier,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    roll1==rootCategoriesList[index]['title']?   Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                            onTap:(){
                                             showHideSublistProvider.update(true);
                                            },
                                            child: Icon(Icons.add,color: selectedCategoryColor,size: 18,)),
                                        SizedBox(width: 7,),
                                        GestureDetector(
                                            onTap:(){
                                              showHideSublistProvider.update(false);
                                            },
                                            child: Icon(Icons.remove,color: selectedCategoryColor,size: 18,)),
                                      ],
                                    ):
                                    Container()

                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      ),
                     Consumer<ShowHideSublistProvider>(builder: (context,showHideProvider,_){
                       return Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisSize: MainAxisSize.min,
                         children: [
                       showHideProvider.showCategoryRow?  SizedBox(height: 5,):Container(),
                       showHideProvider.showCategoryRow? Row(
                       children: [
                       SizedBox(width: 20,),
                       categoryRow(w, h),
                       ],
                       ):Container()
                         ],
                       );
                     })
                    ],
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
  Future<List<String>> getUrlFields({required String sublistName}) async {
    List<String> urlList = [];

    try{

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(sublistName).get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        if (data!=null && data.containsKey('url')) {
          String url = data['url'] as String;
          urlList.add(url);
        }
      }
      return urlList;
    }
    catch(e){
      print(e.toString);
      return urlList;
    }

  }
  TextEditingController categoryNameEditController = TextEditingController();
  final sublistNoteFormKey = GlobalKey<FormState>();
  final categoryNameEditFormKey = GlobalKey<FormState>();
  List<String> docIdsSublistSharing = [];
  Map<String,dynamic> isSublistSharingContactList = {};

  List<bool> sublistNameSelectedIndex = [];
  Widget categoryRow(double w, double h) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    ShareOptionsProviderSublist shareOptionsProviderSublist = Provider.of<ShareOptionsProviderSublist>(context,listen: true);
    SublistNameEditProvider sublistNameEditProviderr = Provider.of<SublistNameEditProvider>(context,listen:false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 320,
            // height: h * 0.6,
            padding: EdgeInsets.only(left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail)
                        .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists')
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
                        // sublistNameSelectedIndex.clear();
                        // for(int i=0;i<docs.length;++i){
                        // }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            categoryProvider.add(false);
                            final data = docs[index].data();
                            sublistNameEditProviderr.initialize();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 85,
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
                                          final fontSizeProvider = Provider.of<FontSizeProvider>(context);
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Consumer<SublistNameEditProvider>(builder:(context,sublistNameEditProvider,_){
                                                  return
                                                    GestureDetector(
                                                    onDoubleTap: ()async{
                                                      try{
                                                        // setState(() {
                                                        //   sublistNameSelectedIndex[index]=!sublistNameSelectedIndex[index];
                                                        // });
                                                        sublistNameEditProviderr.reset();
                                                        sublistNameEditProviderr.flip(index);
                                                        //  CollectionReference mySublistsRef =
                                                        //  FirebaseFirestore.instance
                                                        //      .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                        //  DocumentSnapshot sublistDocSnap = await mySublistsRef.doc(data['docId']).get();
                                                        //  String categoryName  = '';
                                                        //
                                                        // try{
                                                        //    categoryName = await sublistDocSnap['updatedCategoryName'];
                                                        //  }
                                                        //  catch(e){
                                                        //
                                                        //  }
                                                        //  showDialog(context: context, builder:(context){
                                                        //    return AlertDialog(
                                                        //      backgroundColor: white,
                                                        //      elevation: 5,
                                                        //      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                        //      scrollable: true,
                                                        //      shadowColor: textColor,
                                                        //      surfaceTintColor: offWhite,
                                                        //      alignment: Alignment.center,
                                                        //      content: Center(
                                                        //          child:
                                                        //          Form(
                                                        //            key: categoryNameEditFormKey,
                                                        //            child: Column(
                                                        //              crossAxisAlignment: CrossAxisAlignment.center,
                                                        //              mainAxisAlignment: MainAxisAlignment.center,
                                                        //              children: [
                                                        //                Container(
                                                        //                  constraints: BoxConstraints(maxHeight: 300,maxWidth: 400,minWidth: 400,minHeight:300 ),
                                                        //                  decoration: BoxDecoration(
                                                        //                      color: white,
                                                        //                      borderRadius: BorderRadius.circular(15)
                                                        //                  ),
                                                        //                  child: Center(
                                                        //                    child: textRobotoMessage(categoryName==''?sublistDocSnap['categoryName']:'Sublist Name : '+ categoryName, green, w400, categoryName=='Empty'?size15:size12),
                                                        //                  ),
                                                        //                ),
                                                        //                SizedBox(height: 7,),
                                                        //
                                                        //                TextFormField(
                                                        //                  validator: (v){
                                                        //                    return v!.length<2?'Please enter a name!':null;
                                                        //                  },
                                                        //                  controller: categoryNameEditController,
                                                        //                  decoration: InputDecoration(
                                                        //                    labelText: 'Edit name (Optional)',
                                                        //                    border: OutlineInputBorder(
                                                        //                        borderRadius: BorderRadius.circular(12)),
                                                        //                    errorBorder: OutlineInputBorder(
                                                        //                        borderSide:
                                                        //                        BorderSide(color: Colors.indigo, width: 2),
                                                        //                        borderRadius: BorderRadius.circular(12)),
                                                        //                    focusedBorder: OutlineInputBorder(
                                                        //                        borderSide:
                                                        //                        BorderSide(color: Colors.indigo, width: 2),
                                                        //                        borderRadius: BorderRadius.circular(12)),
                                                        //                  ),
                                                        //                ),
                                                        //                SizedBox(height: 7,),
                                                        //
                                                        //                Row(
                                                        //                  mainAxisAlignment: MainAxisAlignment.center,
                                                        //                  crossAxisAlignment: CrossAxisAlignment.center,
                                                        //                  children: [
                                                        //                    GestureDetector(
                                                        //                      onTap: (){
                                                        //                        Navigator.pop(context);
                                                        //                      },
                                                        //                      child: Container(
                                                        //                        width: 100,
                                                        //                        height: 40,
                                                        //                        decoration: BoxDecoration(
                                                        //                            color: Colors.blueGrey,
                                                        //                            borderRadius: BorderRadius.circular(20)
                                                        //                        ),
                                                        //                        child: Center(
                                                        //                          child: textRubik('Cancel', Colors.black87,w500, size14),
                                                        //                        ),
                                                        //                      ),
                                                        //                    ),
                                                        //                    SizedBox(width: 7,),
                                                        //                    GestureDetector(
                                                        //                      onTap: ()async{
                                                        //                        if(categoryNameEditFormKey.currentState!.validate()){
                                                        //                          categoryNameEditFormKey.currentState!.save();
                                                        //                          try{
                                                        //                            CollectionReference mySublistsRef =
                                                        //                            FirebaseFirestore.instance
                                                        //                                .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                        //                            await mySublistsRef.doc(data['docId']).update({
                                                        //                              'updatedCategoryName':categoryNameEditController.text.toString()
                                                        //                            }).then((value) {
                                                        //                              Navigator.pop(context);
                                                        //                            });
                                                        //
                                                        //                          }
                                                        //                          catch(e){
                                                        //                            Fluttertoast.showToast(msg: 'Could not save name!');
                                                        //                            print(e.toString());
                                                        //                          }
                                                        //                        }
                                                        //                      },
                                                        //                      child: Container(
                                                        //                        width: 100,
                                                        //                        height: 40,
                                                        //                        decoration: BoxDecoration(
                                                        //                            color: btnBgColor,
                                                        //                            borderRadius: BorderRadius.circular(20)
                                                        //                        ),
                                                        //                        child: Center(
                                                        //                          child: textRubik('Save', Colors.black87,w500, size14),
                                                        //                        ),
                                                        //                      ),
                                                        //                    )
                                                        //                  ],
                                                        //                )
                                                        //              ],
                                                        //            ),
                                                        //          )
                                                        //      ),
                                                        //    );
                                                        //  },);
                                                      }
                                                      catch(e){
                                                        print(e.toString());
                                                      }
                                                    },
                                                    onTap: () {
                                                      try{
                                                        setState((){
                                                          mySublistDocId=data['docId'];
                                                        });

                                                        categoryProvider
                                                            .setTitle(data['docId']);
                                                        categoryProvider.setSelectedIndex(index);
                                                      }catch(e){
                                                        print(e.toString());
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 200,
                                                      child: sublistNameEditProviderr.sublistNameSelectedIndex[index]?
                                                      Container(
                                                        width:170,
                                                        child: TextFormField(

                                                          controller: categoryNameEditController,
                                                          decoration: InputDecoration(
                                                            hintText: data['updatedCategoryName']??data['categoryName'],
                                                          ),
                                                          onFieldSubmitted: (v)async{
                                                            if(categoryNameEditController.text.isNotEmpty){
                                                              try{
                                                                CollectionReference mySublistsRef = FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                                await mySublistsRef.doc(data['docId']).update({
                                                                  'updatedCategoryName':categoryNameEditController.text.toString()
                                                                }).then((value) {
                                                                  categoryNameEditController.clear();
                                                                  sublistNameEditProviderr.turnOff(index);

                                                                });
                                                              }
                                                              catch(e){

                                                                Fluttertoast.showToast(msg: 'Could not save name!');
                                                                print(e.toString());
                                                                categoryNameEditController.clear();
                                                                sublistNameEditProviderr.turnOff(index);

                                                              }
                                                            }
                                                            else{
                                                              sublistNameEditProviderr.turnOff(index);
                                                            }


                                                          },
                                                        ),
                                                      ):
                                                      textRoboto(
                                                        data['updatedCategoryName']??data['categoryName'],
                                                        categoryProvider.categoryBoolList[index]
                                                            ? selectedCategoryColor
                                                            : textColor,
                                                        w400,
                                                        size16*fontSizeProvider.fontSizeMultiplier,
                                                      ),
                                                    ),
                                                  );

                                          }),
                                                  GestureDetector(
                                                    onTap:()async{
                                                      try{
                                                        CollectionReference mySublistsRef =
                                                        FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail)
                                                            .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                      DocumentSnapshot sublistDocSnap = await mySublistsRef.doc(data['docId']).get();
                                                      String note  = '';

                                                            try{
                                                              note = await sublistDocSnap['sublistNote'];
                                                            }
                                                            catch(e){
                                                              note = '';
                                                            }

                                                        showDialog(context: context, builder:(context){
                                                          return AlertDialog(
                                                            backgroundColor: white,
                                                            elevation: 5,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                            scrollable: true,
                                                            shadowColor: textColor,
                                                            surfaceTintColor: offWhite,
                                                            alignment: Alignment.center,
                                                            content: Center(
                                                                child:
                                                                Form(
                                                                  key: sublistNoteFormKey,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        constraints: BoxConstraints(maxHeight: 300,maxWidth: 400,minWidth: 400,minHeight:300 ),
                                                                        decoration: BoxDecoration(
                                                                            color: white,
                                                                            borderRadius: BorderRadius.circular(15)
                                                                        ),
                                                                        child: Center(
                                                                          child: textRobotoMessage(note==''?'No note has been saved':note, green, w400, note=='Empty'?size15:size12),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 7,),

                                                                      TextFormField(
                                                                        validator: (v){
                                                                          return v!.length<2?'Please enter a note!':null;
                                                                        },
                                                                        controller: sublistNoteController,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'Edit note (Optional)',
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
                                                                      SizedBox(height: 7,),

                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [
                                                                          GestureDetector(
                                                                            onTap: (){
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: Container(
                                                                              width: 100,
                                                                              height: 40,
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.blueGrey,
                                                                                  borderRadius: BorderRadius.circular(20)
                                                                              ),
                                                                              child: Center(
                                                                                child: textRubik('Cancel', Colors.black87,w500, size14),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 7,),
                                                                          GestureDetector(
                                                                            onTap: ()async{
                                                                              if(sublistNoteFormKey.currentState!.validate()){
                                                                                sublistNoteFormKey.currentState!.save();
                                                                                try{
                                                                                  CollectionReference mySublistsRef =
                                                                                  FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail)
                                                                                      .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                                                  await mySublistsRef.doc(data['docId']).update({
                                                                                    'sublistNote':sublistNoteController.text.toString()
                                                                                  }).then((value) {
                                                                                    Navigator.pop(context);
                                                                                  });

                                                                                }
                                                                                catch(e){
                                                                                  Fluttertoast.showToast(msg: 'Could not save note!');
                                                                                  print(e.toString());
                                                                                }
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              width: 100,
                                                                              height: 40,
                                                                              decoration: BoxDecoration(
                                                                                  color: btnBgColor,
                                                                                  borderRadius: BorderRadius.circular(20)
                                                                              ),
                                                                              child: Center(
                                                                                child: textRubik('Save', Colors.black87,w500, size14),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                            ),
                                                          );
                                                        },);

                                                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Deleted Successfully!', white,w400, size13)));
                                                      }
                                                      catch(e){
                                                        print(e.toString());
                                                      }
                                                    },
                                                    child:  Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration:
                                                      BoxDecoration(
                                                        shape:
                                                        BoxShape.circle,
                                                        color:
                                                        white,
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
                                                  SizedBox(width:3),
                                                  GestureDetector(
                                                    onTap:()async{
                                                      try{
                                                        CollectionReference mySublistsRef =
                                                        FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail)
                                                            .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                       await mySublistsRef.doc(data['docId']).delete().then((value) {
                                                         Fluttertoast.showToast(msg: 'deleted!');
                                                         setState(() {

                                                         });
                                                         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Deleted Successfully!', white,w400, size13)));
                                                       });
                                                      }
                                                      catch(e){
                                                        print(e.toString());
                                                      }
                                                    },
                                                    child: Icon(Icons.delete,),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 5,),
                                              categoryProvider.categoryBoolList[index]
                                                  ?     Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  TextButton(onPressed: ()async{
                                                    try{
                                                      print('share');
                                                      ShareListProviderSublist shareListProviderSublist = Provider.of<ShareListProviderSublist>(context,listen:false);
                                                      CollectionReference mySublistsRef =
                                                      FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail)
                                                          .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                      DocumentSnapshot sublistSnap = await mySublistsRef.doc(await data['docId']).get();
                                                      String sublistName = await sublistSnap['categoryName'];

                                                    List<String> value = await getUrlFields(sublistName: sublistName);
                                                        print(value);
                                                        String allUrlsInsideMySublist_Concatenated = '';

                                                        // if(allUrlsInsideMySublist.isNotEmpty){
                                                        for(String url in value){
                                                          allUrlsInsideMySublist_Concatenated += url+', ';
                                                          // }
                                                        }
                                                        allUrlsInsideMySublist_Concatenated = removeDuplicates(allUrlsInsideMySublist_Concatenated);
                                                        print('allUrlsInsideMySublist_Concatenated :');
                                                        print(allUrlsInsideMySublist_Concatenated);

                                                        // await createPDF(allUrlsInsideMySublist_Concatenated);

                                                        shareUrlSublist = allUrlsInsideMySublist_Concatenated;
                                                      shareListProviderSublist.setSharingUrl(allUrlsInsideMySublist_Concatenated);
                                                        showCustomDialogSublist(context);
                                                                print(shareOptionsProviderSublist.shareOption!=''?shareOptionsProviderSublist.shareOption:'null');


                                                    }
                                                    catch(e){
                                                      Fluttertoast.showToast(msg:e.toString());
                                                      print(e.toString());
                                                    }
                                                  }, child: textRubik('Share', selectedCategoryColor, w500, size14)),
                                                  SizedBox(width:8),
                                                  TextButton(onPressed: ()async{
                                                    print('print');
                                                    try{
                                                      CollectionReference mySublistsRef =
                                                      FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail)
                                                          .collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists');
                                                      DocumentSnapshot sublistSnap = await mySublistsRef.doc(await data['docId']).get();
                                                      String sublistName = await sublistSnap['categoryName'];
                                                      print(sublistName);
                                                      List<String> allUrlsInsideMySublist = await getUrlFields(sublistName: sublistName);
                                                  //     print(allUrlsInsideMySublist);
                                                      String allUrlsInsideMySublist_Concatenated = '';

                                                      // if(allUrlsInsideMySublist.isNotEmpty){
                                                        for(String url in allUrlsInsideMySublist){
                                                          allUrlsInsideMySublist_Concatenated += url+'\n';
                                                        // }
                                                  print('url');
                                                      }
                                                      allUrlsInsideMySublist_Concatenated = removeDuplicates(allUrlsInsideMySublist_Concatenated);
                                                        print('allUrlsInsideMySublist_Concatenated :');
                                                        print(allUrlsInsideMySublist_Concatenated);

                                                      await createPDF(allUrlsInsideMySublist_Concatenated);
                                                    }
                                                    catch(e){
                                                      Fluttertoast.showToast(msg:e.toString());
                                                      print(e.toString());
                                                    }
                                                  }, child: textRubik('Print', selectedCategoryColor, w500, size14)),

                                                ],
                                              ):Container()
                                            ],
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),

                              ],
                            );
                          },
                          itemCount: docs.length,
                          scrollDirection: Axis.vertical,
                        );
                      }
                    }),
                SizedBox(height: 20,),
                GestureDetector(
                  onTap: () async {
                    try{
                      DocumentSnapshot snap = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();
                      if(rollDuplicate==snap['roll']){
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
                      }
                    }
                    catch(e){
                      Fluttertoast.showToast(msg: 'Please  try again!');
                    }
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

              ],
            ),
          ),
          SizedBox(
            height: h * 0.02,
          ),
        ],
      ),
    );
  }
  Widget shareSublistContainer(double w,double h){

    ShareListProviderSublist shareListProvider = Provider.of<ShareListProviderSublist>(context,listen: false);
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: false);
    ShareOptionsProviderSublist shareOptionsProvider = Provider.of<ShareOptionsProviderSublist>(context,listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
          child: Container(
          width:fontSizeProvider.fontSizeMultiplier<=1?330:330*fontSizeProvider.fontSizeMultiplier,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textRubik('Forward To ',textColor,w500, size18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    GestureDetector(
                        onTap:(){
                          shareOptionsProvider.reset();
                        },
                        child: textRubik('Cancel', textColor, w600,size17)),
                    SizedBox(width: 6,),

                    GestureDetector(
                        onTap:()async{
                          processSelectedItemsSublist(shareListProvider.shareList,shareUrlSublist);
                        },
                        child: textRubik('Send', green, w600,size17)),
                  ],
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 15,),
        Stack(
          children: [
            Container(
                width: fontSizeProvider.fontSizeMultiplier<=1?330:330*fontSizeProvider.fontSizeMultiplier,
                height: h*0.74,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),),
                child:

                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                    stream:    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                        .snapshots(),
                    builder: (context, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapShot.hasError) {
                        return Center(
                          child: textRoboto('Error loading messages', textColor, w400, size16),
                        );
                      } else {

                        List docs = snapShot.data!.docs;

// Function to parse date and time strings into DateTime
                        if(contactSearchText!=''){

                          docs = docs
                              .where((doc) =>
                          (doc['firstName']+doc['lastName'] as String).toLowerCase().contains(contactSearchText)
                              ||
                              (doc['roll'] as String).toLowerCase().contains(contactSearchText)
                          )
                              .toList();
                        }
                        return ListView.builder(itemBuilder: (context,index){
                          final data = docs[index].data();
                          shareListProvider.update({
                            'uid': data['uid'],
                            'isSelected':false
                          });
                          return Padding(
                            padding:EdgeInsets.only(bottom:index==docs.length-1?60:0),
                            child: InkWell(
                              onTap: () async {
                                try {

                                  shareListProvider.flipIsSelected(index);

                                } catch (e) {
                                  print(e.toString());
                                  Fluttertoast.showToast(
                                      msg: 'Cannot contact right now!');
                                }

                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                width: fontSizeProvider.fontSizeMultiplier<=1?330:330*fontSizeProvider.fontSizeMultiplier,
                                height: fontSizeProvider.fontSizeMultiplier<=1?70:70*fontSizeProvider.fontSizeMultiplier,
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
                                                width: 40*fontSizeProvider.fontSizeMultiplier,
                                                height: 40*fontSizeProvider.fontSizeMultiplier,
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
                                                width: 10*fontSizeProvider.fontSizeMultiplier,
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
                                                      size16*fontSizeProvider.fontSizeMultiplier),
                                                  SizedBox(
                                                    height: 1.5*fontSizeProvider.fontSizeMultiplier,
                                                  ),
                                                  textRoboto(data['roll'],
                                                      textColor, w400, size14*fontSizeProvider.fontSizeMultiplier)
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                              width: 35*fontSizeProvider.fontSizeMultiplier,
                                              height: 35*fontSizeProvider.fontSizeMultiplier,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  // color:  shareListProvider.shareList[index]['isSelected']?textColor:Colors.orange,
                                                  border: Border.all(color: Colors.black,width: 1.5)
                                              ),
                                              padding: EdgeInsets.all(2),
                                              child:  Consumer<ShareListProviderSublist>(builder:(context,shareListProviderr,_){
                                                return shareListProviderr.shareList[index]['isSelected']?Center(
                                                    child:Container(
                                                      width: 32*fontSizeProvider.fontSizeMultiplier,
                                                      height: 32*fontSizeProvider.fontSizeMultiplier,
                                                      decoration: BoxDecoration(
                                                          color: btnBgColor,
                                                            shape: BoxShape.circle
                                                      ),
                                                    )
                                                ):Container();
                                              })
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
                            ),
                          );
                        },itemCount: docs.length,)  ;

                      }})
            ),

          ],
        ),
      ],
    );

  }

  Widget shareSublistsContainer(double w, double h){
    ShareOptionsProviderSublist shareOptionsProviderSublist = Provider.of<ShareOptionsProviderSublist>(context,listen:false);
    return Container(
      width: 330,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 330,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                textRubik('Forward To',textColor,w500, size28),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap:(){
                        shareOptionsProviderSublist.reset();
                      },

                        child: textRubik('Cancel',textColor,w500, size22)),
                    SizedBox(width:8),
                    textRubik('Send',selectedCategoryColor,w500, size22),
                  ],
                )

              ],
            ),
          ),
          SizedBox(height: 15,),
          Stack(
            children: [
              Container(
                  width: 330,
                  height: h*0.74,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(8),),
                  child:

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                      stream:    FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users')
                          .snapshots(),
                      builder: (context, snapShot) {
                        if (snapShot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),

                          );
                        } else if (snapShot.hasError) {
                          return Center(
                            child: textRoboto('Error loading Contacts', textColor, w400, size16),
                          );
                        } else {

                          List docs = snapShot.data!.docs;
                          if(docs.isEmpty){
                            return Center(child:textRubik('No Contacts Found!',textColor, w400,size10));
                          }
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
                            return InkWell(
                              onTap: () async {
                                try {
                                  await creatingChat(data,index).then((value) async{
                                    // print(value[0]+' '+value[1]+' '+value[2]);
                                    String image = data['imageUrl'];
                                    String name = capitalizeFirstLetter(await data['firstName'])+" "+capitalizeFirstLetter(await data['lastName']);
                                    String roll = await data['roll'];
                                    String receiverId = value[2];
                                    String docId = value[0];
                                    UnreadMessagesDashboardProvider unreadMessagesDashboardProvider = Provider.of<UnreadMessagesDashboardProvider>(context,listen: false);
                                    unreadMessagesDashboardProvider.reset();

                                  });

                                } catch (e) {
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
                                                  textRoboto("${capitalizeFirstLetter(data['firstName'])} ${capitalizeFirstLetter(data['lastName'])}", textColor, w500, size16),
                                                  SizedBox(
                                                    height: 1.5,
                                                  ),
                                                  textRoboto(data['roll'], textColor, w400, size14)
                                                ],
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap:(){

                                              print(isSublistSharingContactList);
                                            },
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: textColor,width:1.5)
                                              ),
                                              padding: EdgeInsets.all(1),
                                              child: Center(
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: isSublistSharingContactList[index]['isSelected']?
                                                        textColor:white
                                                    ),
                                                  )
                                              ),
                                            ),
                                          )

                                          // textRubik(unreadMessagesDashboardProvider.uid_unread[index][data['uid']??'']!='0'?unreadMessagesDashboardProvider.uid_unread[index][data['uid']]:'', textColor,w500,size11)

                                          // textRubik(uid_unread[index][data['uid']??'']!='0'?uid_unread[index][data['uid']]:'', textColor,w500,size11)
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
                          },itemCount: docs.length,)  ;




                        }})
              ),
              Positioned(child:        Container(
                width: 330,
                height: 70,
                decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(10)
                ),                child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                width: 310,
                height: 40,
                decoration: BoxDecoration(
                    color: offWhite,
                    borderRadius: BorderRadius.circular(10)
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 10),
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
      ),
    );
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

  Widget linkLogRowMobile(double w) {


    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    return Padding(
      padding: EdgeInsets.only(left: w * 0.1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            textRubik("$corporationName Link Log", textColor,
                w500, size28*fontSizeProvider.fontSizeMultiplier),
            SizedBox(width: 20,),
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
                GestureDetector(
                    onTap: (){

                      if(textColor == color1){
                        setState(() {
                          textColor=white;
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
                textRoboto('Font size', textColor, w400, size14*fontSizeProvider.fontSizeMultiplier),
                SizedBox(
                  width: 10,
                ),
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

  Widget linkLogRow(double w) {


    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    return Padding(
      padding: EdgeInsets.only(left: w * 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          textRubik("$corporationName Link Log", textColor,
              w500, size28*fontSizeProvider.fontSizeMultiplier),
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
              GestureDetector(
                  onTap: (){

                  if(textColor == color1){
                    setState(() {
                      textColor=white;
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
              textRoboto('Font size', textColor, w400, size14*fontSizeProvider.fontSizeMultiplier),
              SizedBox(
                width: 10,
              ),
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

  Widget appBarMobile(double w, String username, String roll, String _imageUrl) {
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    SearchProvider searchProvider = Provider.of<SearchProvider>(context,listen: false);
    return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logoText.png',
                width: 100*2 * fontSizeProvider.fontSizeMultiplier,
              ),
              SizedBox(width: 10,),
              SizedBox(
                width: w*0.03,
              ),
              Container(
                width: w * 0.3,
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
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              color:textColor != color1  ?Colors.grey[800]!: textColor,
                              letterSpacing: .5,
                              fontWeight: w400,
                              fontSize: size14),
                        ),
                        onChanged: (v){
                          searchProvider.update(v);
                        },
                        cursorColor: textColor,
                        decoration: InputDecoration.collapsed(
                          hintText:
                          'Search keywords, URLs, links or meta descriptions',
                          hintStyle: GoogleFonts.roboto(
                            textStyle: TextStyle(
                                color: textColor != color1  ?Colors.grey[800]!:textColor,
                                letterSpacing: .5,
                                fontWeight: w400,
                                fontSize: size11),
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

              SizedBox(
                width: w * 0.05,
              ),
              InkWell(
                onTap: () async {
                  await _selectAndDisplayImage().then((value) async {
                    if (_imageFileDP != null) {
                      await _uploadImageDP().then((value) async {

                        await FirebaseFirestore.instance
                            .collection(corporationEmail).doc(corporationEmail).collection('Users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'imageUrl': imageUrlDP.isNotEmpty
                              ? imageUrlDP
                              : 'https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/profileImagePlaceHolder.png?alt=media&token=9d64cc25-ec5e-4360-9bd4-0c0663c2f143'
                        }).then((value) {
                          print(imageUrlDP);
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
                    width: 32,
                    height: 32,
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
                  textRoboto(username, textColor, w500, size16 * fontSizeProvider.fontSizeMultiplier),
                  SizedBox(
                    height: 4,
                  ),
                  textRubik(roll, textColor, w400, size10 * fontSizeProvider.fontSizeMultiplier),
                ],
              ),
              SizedBox(
                width: w * 0.005,
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: lightGrey, size: 18),
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
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app, color: Colors.black),
                          SizedBox(width: 4),
                          textRoboto('Logout', textColor, w500, size11),
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

  Widget appBar(double w, String username, String roll, String _imageUrl) {
    FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: true);

    SearchProvider searchProvider = Provider.of<SearchProvider>(context,listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/logo.png',
            //   width: 55,
            //   height: 55,
            // ),
            // SizedBox(
            //   width: 10,
            // ),
            Image.asset(
              'assets/logoText.png',
              width: 100*2 * fontSizeProvider.fontSizeMultiplier,
            ),
            SizedBox(width: 10,),
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
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            color:textColor != color1  ?Colors.grey[800]!: textColor,
                            letterSpacing: .5,
                            fontWeight: w400,
                            fontSize: size14),
                      ),
                      onChanged: (v){
                        searchProvider.update(v);
                      },
                      cursorColor: textColor,
                      decoration: InputDecoration.collapsed(
                        hintText:
                        'Search keywords, URLs, links or meta descriptions',
                        hintStyle: GoogleFonts.roboto(
                          textStyle: TextStyle(
                              color: textColor != color1  ?Colors.grey[800]!:textColor,
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
            // Image.asset(
            //   'assets/notificationIcon.png',
            //   width: 40,
            //   height: 40,
            // ),
            SizedBox(
              width: w * 0.006,
            ),
            InkWell(
              onTap: () async {
                await _selectAndDisplayImage().then((value) async {
                  if (_imageFileDP != null) {
                    await _uploadImageDP().then((value) async {

                      await FirebaseFirestore.instance
                          .collection(corporationEmail).doc(corporationEmail).collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        'imageUrl': imageUrlDP.isNotEmpty
                            ? imageUrlDP
                            : 'https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/profileImagePlaceHolder.png?alt=media&token=9d64cc25-ec5e-4360-9bd4-0c0663c2f143'
                      }).then((value) {
                        print(imageUrlDP);
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
                textRoboto(username, textColor, w500, size16 * fontSizeProvider.fontSizeMultiplier),
                SizedBox(
                  height: 4,
                ),
                textRubik(roll, textColor, w400, size10 * fontSizeProvider.fontSizeMultiplier),
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
    if (pickedFile == null){
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('No Image Selected!',white,w400, size12)));
      return;
    } ;
    setState(() {
      _imageFileDP = File(pickedFile.path);
    });
    // print(_imageFileDP);
  }

  String categoryImageUrl = "";
  String imageUrlDP = "";
  bool isSelected = false;
  bool isSelectedDP = false;

  // Future<bool> _uploadImage() async {
  //   try {
  //     if (_imageFile == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Please select an image first.'),
  //         ),
  //       );
  //       isSelected = false;
  //       return isSelected;
  //     }
  //
  //     final fileName = _imageFile!.path.split('/').last;
  //
  //     final ref = await _storage.ref().child('images/$fileName');
  //
  //     if (kIsWeb) {
  //       Uint8List imageData = await XFile(_imageFile!.path).readAsBytes();
  //
  //       UploadTask uploadTask = ref.putData(
  //         imageData,
  //         SettableMetadata(contentType: 'image/png'),
  //       );
  //
  //       // TaskSnapshot snapshot = await uploadTask;
  //
  //       final imageUrl = await ref.getDownloadURL();
  //
  //       setState(() {
  //         categoryImageUrl = imageUrl;
  //         isSelected = true;
  //       });
  //
  //       return isSelected;
  //     } else {
  //       await ref.putFile(_imageFile!);
  //     }
  //
  //     final imageUrl = await ref.getDownloadURL();
  //
  //     setState(() {
  //       categoryImageUrl = imageUrl;
  //       isSelected = true;
  //     });
  //     return isSelected;
  //   } catch (e) {
  //     print(e.toString());
  //     return false;
  //   }
  // }
  Future<bool> _uploadImage() async {
    try {
      if (_imageFile == null) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Please select an image first.'),
        //   ),
        // );
        isSelected = false;
        return isSelected;
      }

      final ref = _storage.ref().child(DateTime.now().millisecondsSinceEpoch.toString()); // Use a unique identifier for the file name

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFile!.path).readAsBytes();

        await ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/png'),
        );

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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Please select an image first.'),
        //   ),
        // );
        isSelectedDP = false;
        return isSelectedDP;
      }

      String fileName = '${FirebaseAuth.instance.currentUser!.uid}DP';
      Reference ref = _storage.ref().child('images/$fileName');

      if (kIsWeb) {
        Uint8List imageData = await XFile(_imageFileDP!.path).readAsBytes();

        await ref.putData(
          imageData,
          SettableMetadata(contentType: 'image/jpeg'), // Specify content type for web
        );

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
            height: 280,
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
                        // print('file selected');
                        // print(_imageFile);
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
                  SizedBox(height:8),
                  TextFormField(
                    controller: sublistNoteController,
                    decoration: InputDecoration(
                      labelText: 'Note (Optional)',
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
                        String sublistNote = 'Empty';
                        if(sublistNoteController.text.isNotEmpty){
                          sublistNote = sublistNoteController.text.toString();
                        }
                        try {
                          setState(() {
                            isLoading2 = true;
                          });
                          await _uploadImage().then((value) async{
                            final DocumentReference docRef =
                            FirebaseFirestore.instance
                                .collection(corporationEmail).doc(corporationEmail).collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists')
                                .doc(subListName);
                            // Check if the document already exists
                            final DocumentSnapshot docSnapshot =
                            await docRef.get();

                            if (docSnapshot.exists) {
                              // Document already exists, update the fields

                              //Updated Version Code
                              DocumentReference ref =   await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).doc(FirebaseAuth.instance.currentUser!.uid).collection('MySublists').add({
                                'categoryName': subListName,
                                'sublistNote' : sublistNote,
                                'categoryImage':  value
                                    ? categoryImageUrl
                                    : "https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/subListIcon.png?alt=media&token=76b450e4-4f50-45c7-a093-7ba5c8627e0b",
                              });
                              await ref.update({'docId':ref.id}).then((value) {
                                Navigator.pop(context);
                                setState(() {
                                  isLoading2 = false;
                                });
                              });
                            } else {
                              // Document does not exist, create it
                              await docRef.set({
                                'categoryName': subListName,
                                'sublistNote' : sublistNote,
                                'categoryImage': value
                                    ? categoryImageUrl
                                    : "https://firebasestorage.googleapis.com/v0/b/url2goweb.appspot.com/o/subListIcon.png?alt=media&token=76b450e4-4f50-45c7-a093-7ba5c8627e0b"
                              }).then((value) async{
                                await docRef.update({'docId':docRef.id});
                                sublistController.clear();
                                Navigator.pop(context);
                                setState(() {
                                  isLoading2 = false;
                                });
                              });
                            }
                          });


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

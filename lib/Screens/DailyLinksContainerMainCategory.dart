import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url2goweb/Providers/FontSizeProvider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MetaDataFetch/MetaData.dart';
import '../Properties/Colors.dart';
import '../Properties/fontSizes.dart';
import '../Properties/fontWeights.dart';
import '../Providers/CategoryProviderMessenger.dart';
import '../Providers/DateProvider.dart';
import '../Providers/ShareListProviderMultipleMainCategory.dart';
import '../Providers/ShareOptionsDailyLinksMainCategoryProvider.dart';
import '../Providers/checkBoxMainCategoryConsumer.dart';
import '../Utils/CalendarWidget.dart';
import '../Utils/MultipleUrlsShareDialogForDailyLinksMainCategory.dart';
import '../Utils/PdfPrint.dart';
import '../Utils/text.dart';
import 'dailyLinksContainer.dart';



void sendMessage(String v,String user2Uid, String senderUid,context,String corporationEmail)async{
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

Future<void> forwardUrl(List<String> selectedUids,String sharingUrl,context,String corporationEmail)async{
  try{
    ShareOptionsDailyLinksMainCategoryProvider shareOptionsProvider = Provider.of<ShareOptionsDailyLinksMainCategoryProvider>(context,listen: false);
    shareOptionsProvider.reset();
    for(String uid in selectedUids){
      sendMessage(allUrlsConcatenated, uid, FirebaseAuth.instance.currentUser!.uid,context,corporationEmail);
    }
  }
  catch(e){
    print(e.toString());
  }
}

void processSelectedItems(List<Map<String, dynamic>> shareList,String sharingUrl,context,String corporationEmail) {
  bool anySelected = false;
  List<String> selectedUids = [];

  for (final item in shareList) {
    if (item['isSelected']) {
      anySelected = true;
      // print('selected');
      selectedUids.add(item['uid']);
    }
  }
  ShareListProviderMultipleMainCategory shareListProvider = Provider.of<ShareListProviderMultipleMainCategory>(context,listen: false);
  ShareOptionsDailyLinksMainCategoryProvider shareOptionsProvider = Provider.of<ShareOptionsDailyLinksMainCategoryProvider>(context,listen: false);
  if (anySelected) {
    forwardUrl(selectedUids,sharingUrl,context,corporationEmail).then((value) {
      shareListProvider.reset();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: textRubik('Forwarded Successfully', white, w400, size14)));
    });
  }
  else{
    // shareOptionsProvider.reset();

  }

  // print(selectedUids);
}

Widget messagesContainerForSharing(double w,double h,BuildContext context,String corporationEmail){

  ShareListProviderMultipleMainCategory shareListProvider = Provider.of<ShareListProviderMultipleMainCategory>(context,listen: false);
  ShareOptionsDailyLinksMainCategoryProvider shareOptionsProvider = Provider.of<ShareOptionsDailyLinksMainCategoryProvider>(context,listen: false);
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
                      processSelectedItems(shareListProvider.shareList,shareListProvider.sharingUrl,context,corporationEmail);
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

                      return ListView.builder(itemBuilder: (context,index){
                        final data = docs[index].data();
                        shareListProvider.update({
                          'uid': data['uid'],
                          'isSelected':false
                        });
                        return Padding(
                          padding:EdgeInsets.only(bottom:index==docs.length-1?80:0),
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
                                            child:  Consumer<ShareListProviderMultipleMainCategory>(builder:(context,shareListProviderr,_){
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






Future<void> delete(var checkBoxConsumer, String roll, List docIds, BuildContext context,String corporationEmail)async{
  if(checkBoxConsumer.checkBoxMap.isNotEmpty){
    for (String docId in docIds) {
      await  FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).doc(docId).delete();
    }


  }
}
Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url),
      mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}
Widget dailyLinksContainerMainCategory(double w, double h,BuildContext context,String roll,bool same,String corporationEmail,FontSizeProvider fontSizeProvider) {
  final fKey = GlobalKey<FormState>();
  TextEditingController addRecentLinkController = TextEditingController();
  TextEditingController addRecentLinkNoteController = TextEditingController();

  return Stack(
    children: [
      Consumer<ShareOptionsDailyLinksMainCategoryProvider>(builder: (context,shareOptionsProvider,_){
        return  Container(
          width: fontSizeProvider.fontSizeMultiplier<=1? 330:330*fontSizeProvider.fontSizeMultiplier,
          // height: fontSizeProvider.fontSizeMultiplier<=1?h * 0.8:h*0.8*fontSizeProvider.fontSizeMultiplier,
          height: h*0.8,
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
          shareOptionsProvider.shareOption=='contact'?
          messagesContainerForSharing(w, h,context,corporationEmail):
          roll.isNotEmpty
              ? SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 14*fontSizeProvider.fontSizeMultiplier),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: 16*fontSizeProvider.fontSizeMultiplier,),
                    textRubik('Daily Links', textColor, w500, size18*fontSizeProvider.fontSizeMultiplier)
                  ],
                ),
                CalendarWidget(),
                SizedBox(height: 8*fontSizeProvider.fontSizeMultiplier,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16*fontSizeProvider.fontSizeMultiplier,
                    ),
                    textRubik('Link List', textColor, w500, size18*fontSizeProvider.fontSizeMultiplier),
                  ],
                ),
                SizedBox(
                  height: 8*fontSizeProvider.fontSizeMultiplier,
                ),
                Container(
                  width: fontSizeProvider.fontSizeMultiplier<=1?326:326*fontSizeProvider.fontSizeMultiplier,
                  height: fontSizeProvider.fontSizeMultiplier<=1?35:35*fontSizeProvider.fontSizeMultiplier,
                  decoration: BoxDecoration(
                      color: pageBackgroundColor,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          try {
                            CheckBoxMainCategoryConsumer checkBoxConsumer = Provider.of<CheckBoxMainCategoryConsumer>(context, listen: false);
                            final checkBoxMap = checkBoxConsumer.checkBoxMap;

                            List<String> docIds = [];
                            List<String> selectedUrls = [];

                            // Iterate through the values of checkBoxMap
                            checkBoxMap.values.forEach((list) {
                              // Iterate through each CheckBoxData instance in the list
                              list.forEach((checkBoxData) {
                                // Check if the checkbox is selected
                                if (checkBoxData.isChecked) {
                                  // Add docId and url to the respective lists only if the checkbox is selected
                                  docIds.add(checkBoxData.docId);
                                  selectedUrls.add(checkBoxData.url);
                                }
                              });
                            });
                            for (String url in selectedUrls) {
                              allUrlsConcatenated += '$url, ';
                            }
                            allUrlsConcatenated = removeDuplicates(allUrlsConcatenated) ;
                            // _onShare(context, allUrlsConcatenated);
                            showCustomDialogUrlsMainCategory(context);
                            print (allUrlsConcatenated);

                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a url first!')));
                            print(e.toString());
                          }
                        },


                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10*fontSizeProvider.fontSizeMultiplier,
                              height: 10*fontSizeProvider.fontSizeMultiplier,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: teal, width: 2*fontSizeProvider.fontSizeMultiplier)
                              ),
                            ),
                            SizedBox(width: 3*fontSizeProvider.fontSizeMultiplier),
                            textRubik('SHARE', textColor, w400, size10*fontSizeProvider.fontSizeMultiplier)
                          ],
                        ),
                      ),

                      Consumer<CheckBoxMainCategoryConsumer>(builder: (context,checkBoxConsumer,_){
                        return                     GestureDetector(
                          onTap: () async {
                            try {
                              // CheckBoxMainCategoryConsumer checkBoxConsumer = Provider.of<CheckBoxMainCategoryConsumer>(context, listen: false);
                              final checkBoxMap = checkBoxConsumer.checkBoxMap;

                              List<String> docIds = [];
                              List<String> selectedUrls = [];

                              // Iterate through the values of checkBoxMap
                              checkBoxMap.values.forEach((list) {
                                // Iterate through each CheckBoxData instance in the list
                                list.forEach((checkBoxData) {
                                  // Check if the checkbox is selected
                                  if (checkBoxData.isChecked) {
                                    // Add docId and url to the respective lists only if the checkbox is selected
                                    docIds.add(checkBoxData.docId);
                                    selectedUrls.add(checkBoxData.url);
                                  }
                                });
                              });
                              await delete(checkBoxConsumer, roll, docIds, context,corporationEmail).then((value) {
                                for (String date in checkBoxConsumer.checkBoxMap.keys) {
                                  checkBoxConsumer.checkBoxMap[date]?.forEach((checkBoxData) {
                                    if (docIds.contains(checkBoxData.docId)) {
                                      checkBoxData.isChecked = false;
                                    }
                                  });
                                }
                                // Notify listeners to rebuild the widget tree and reflect the changes visually
                                checkBoxConsumer.notifyListeners();

                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully!')));
                              });



                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a url first!')));
                              print(e.toString());
                            }
                          },

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10*fontSizeProvider.fontSizeMultiplier,
                                height: 10*fontSizeProvider.fontSizeMultiplier,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: darkYellow, width: 2*fontSizeProvider.fontSizeMultiplier)),
                              ),
                              SizedBox(
                                width: 3*fontSizeProvider.fontSizeMultiplier,
                              ),
                              textRubik('DELETE', textColor, w400, size10*fontSizeProvider.fontSizeMultiplier)
                            ],
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () async {
                          try {
                            final checkBoxConsumer = Provider.of<CheckBoxMainCategoryConsumer>(context, listen: false);
                            final checkBoxMap = checkBoxConsumer.checkBoxMap;

                            List<String> docIds = [];
                            List<String> selectedUrls = [];

                            // Iterate through the values of checkBoxMap
                            checkBoxMap.values.forEach((list) {
                              // Iterate through each CheckBoxData instance in the list
                              list.forEach((checkBoxData) {
                                // Check if the checkbox is selected
                                if (checkBoxData.isChecked) {
                                  // Add docId and url to the respective lists only if the checkbox is selected
                                  docIds.add(checkBoxData.docId);
                                  selectedUrls.add(checkBoxData.url);
                                }
                              });
                            });
                            for(String url in selectedUrls){
                              allUrlsConcatenated += url+', ';
                            }
                            allUrlsConcatenated = removeDuplicates(allUrlsConcatenated);

                            await createPDF(allUrlsConcatenated).then((value) {
                              for (String date in checkBoxConsumer.checkBoxMap.keys) {
                                checkBoxConsumer.checkBoxMap[date]?.forEach((checkBoxData) {
                                  if (docIds.contains(checkBoxData.docId)) {
                                    checkBoxData.isChecked = false;
                                  }
                                });
                              }
                              // Notify listeners to rebuild the widget tree and reflect the changes visually
                              checkBoxConsumer.notifyListeners();


                            });

                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a url first!')));
                            print(e.toString());
                          }

                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10*fontSizeProvider.fontSizeMultiplier,
                              height: 10*fontSizeProvider.fontSizeMultiplier,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                  Border.all(color: teal, width: 2*fontSizeProvider.fontSizeMultiplier)),
                            ),
                            SizedBox(
                              width: 3*fontSizeProvider.fontSizeMultiplier,
                            ),
                            textRubik('PRINT', textColor, w400, size10*fontSizeProvider.fontSizeMultiplier)
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10*fontSizeProvider.fontSizeMultiplier,
                            height: 10*fontSizeProvider.fontSizeMultiplier,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                Border.all(color: blue, width: 2*fontSizeProvider.fontSizeMultiplier)),
                          ),
                          SizedBox(
                            width: 3*fontSizeProvider.fontSizeMultiplier,
                          ),
                          textRubik(
                              'COMPLETED', lightPurple, w400, size10*fontSizeProvider.fontSizeMultiplier)
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5*fontSizeProvider.fontSizeMultiplier,
                ),
                //HERE I NEED TO GET AND DISPLAY THE DATE
                Consumer<DateProvider>(
                  builder: (context, dateProvider, _) {
                    final dateFormat = DateFormat('dd MMM yyyy');
                    final currentDateStr = dateFormat.format(dateProvider.selectedDate);
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: textRoboto('Select a Category', textColor, w400, size13),
                          );
                        } else {
                          List docs = snapshot.data!.docs;

                          // Filter documents based on currentDate
                          final filteredDocs = docs.where((doc) {
                            final data = doc.data();
                            final docDateStr = data['date']; // Assuming date format like "25 Feb 2024"
                            final docDate = dateFormat.parse(docDateStr);

                            return dateFormat.format(docDate) == currentDateStr;

                          }).toList();
                          // dateProvider.resetCheckBoxList();
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              final data = filteredDocs[index].data();
                              final currentDateStr = dateFormat.format(dateProvider.selectedDate);
                              final checkBoxState = Provider.of<CheckBoxMainCategoryConsumer>(context).getCheckBoxList(currentDateStr) ?? [];

                              return Container(
                                margin: EdgeInsets.only(top: fontSizeProvider.fontSizeMultiplier<=1?5:5*fontSizeProvider.fontSizeMultiplier, bottom: index==filteredDocs.length-1?80: 5),
                                width: fontSizeProvider.fontSizeMultiplier<=1?330:330*fontSizeProvider.fontSizeMultiplier,
                                padding: EdgeInsets.only(left:fontSizeProvider.fontSizeMultiplier<=1? 15:15*fontSizeProvider.fontSizeMultiplier, right:fontSizeProvider.fontSizeMultiplier <=1?15:15*fontSizeProvider.fontSizeMultiplier),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Consumer<CheckBoxMainCategoryConsumer>(
                                          builder: (context, checkBoxConsumer, _) {
                                            if (checkBoxState.isEmpty) {
                                              checkBoxConsumer.initializeCheckBoxList(currentDateStr, filteredDocs.length);
                                            }
                                            return Checkbox(
                                              value: index < checkBoxState.length ? checkBoxState[index].isChecked : false,
                                              activeColor: Colors.green,
                                              onChanged: (v) {
                                                checkBoxConsumer.updateCheckBoxList(currentDateStr, index, data['url'], data['docId']);
                                                // checkBoxConsumer.printt();
                                              },
                                            );
                                          },
                                        ),
                                        SizedBox(width: 7),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width:fontSizeProvider.fontSizeMultiplier<=1? 240:240*fontSizeProvider.fontSizeMultiplier,
                                                  child: InkWell(
                                                      onTap:()async{
                                                        try{
                                                          await  _launchUrl(data['url']);
                                                          DocumentReference reference = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).doc(data['docId']);
                                                          DocumentSnapshot snapshot = await reference.get();

                                                          var readByList = await snapshot['readBy'] ;
                                                          readByList.add(FirebaseAuth.instance.currentUser!.uid);

                                                          await reference.update({
                                                            'readBy':FieldValue.arrayUnion(readByList)
                                                          });

                                                        }
                                                        catch(e){
                                                          print(e.toString());
                                                        }
                                                      },
                                                      child: textLink(data['metaData']=='Empty'?data['url']:data['metaData'], textColor, w500, size14*fontSizeProvider.fontSizeMultiplier)),
                                                ),
                                                (data['readBy'] as List<dynamic>).cast<String>().contains(FirebaseAuth.instance.currentUser!.uid)?

                                                Container(
                                                  width: 10*fontSizeProvider.fontSizeMultiplier,
                                                  height: 10*fontSizeProvider.fontSizeMultiplier,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border:
                                                      Border.all(color: blue, width: 2*fontSizeProvider.fontSizeMultiplier)),
                                                ):
                                                Container(
                                                  width: 10*fontSizeProvider.fontSizeMultiplier,
                                                  height: 10*fontSizeProvider.fontSizeMultiplier,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border:
                                                      Border.all(color: Colors.transparent, width: 2*fontSizeProvider.fontSizeMultiplier)),
                                                ),


                                              ],
                                            ),
                                            SizedBox(height: 2*fontSizeProvider.fontSizeMultiplier),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                textRubik(data['date'], textColor, w400, size10*fontSizeProvider.fontSizeMultiplier),
                                                textRubik(' / ', textColor, w400, size10*fontSizeProvider.fontSizeMultiplier),
                                                textRubik(data['time'], textColor, w400, size10*fontSizeProvider.fontSizeMultiplier),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4*fontSizeProvider.fontSizeMultiplier),
                                    DottedLine(
                                      lineThickness: 1,
                                      lineLength: 240*fontSizeProvider.fontSizeMultiplier,
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
                            itemCount: filteredDocs.length,
                          )
                          ;
                        }
                      },
                    );
                  },
                )          ],
            ),
          )



              : Center(
            child: textRubik(
                'Please select a category!', textColor, w400, size13),
          ),
        );
      }),
     same? Positioned(
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              final dateProvider = Provider.of<DateProvider>(context, listen: false);

              final DateTime now =
              DateTime.now();
              final DateFormat
              dateFormat =
              DateFormat('dd MMM yyyy');

              String formattedSelectedDate = dateFormat.format(dateProvider.selectedDate);
              // print(formattedSelectedDate);
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
                            child: Form(
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
                                                  'date': formattedSelectedDate,
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
                                                  addRecentLinkNoteController.clear();
                                                  addRecentLinkController.clear();
                                                  final dateProvider = Provider.of<DateProvider>(context, listen: false);
                                                  final currentDateStr = dateFormat.format(dateProvider.selectedDate);
                                                  final checkBoxConsumer = Provider.of<CheckBoxMainCategoryConsumer>(context, listen: false);
                                                  final checkBoxList = checkBoxConsumer.checkBoxMap[currentDateStr] ?? [];
                                                  final newIndex = checkBoxList.length - 1;
                                                  checkBoxList.add(CheckBoxData(index: newIndex, url: url, docId: newLinkDocId, isChecked: false));
                                                  checkBoxConsumer.updateCheckBoxList(currentDateStr, newIndex, url, newLinkDocId);

// Set all checkboxes to false except for the newly added one
                                                  for (int i = 0; i < checkBoxList.length; i++) {
                                                    if (i == newIndex) {
                                                      checkBoxConsumer.updateCheckBoxList(currentDateStr, i, checkBoxList[i].url, checkBoxList[i].docId);
                                                    }
                                                  }
                                                  Navigator.pop(
                                                      context);
                                                });
                                              } catch (e) {
                                                addRecentLinkNoteController.clear();
                                                addRecentLinkController.clear();
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
                                        SizedBox(height: 8,),
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
                                                  'date': formattedSelectedDate,
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
                                                  addRecentLinkNoteController.clear();
                                                  addRecentLinkController.clear();
                                                  final dateProvider = Provider.of<DateProvider>(context, listen: false);
                                                  final currentDateStr = dateFormat.format(dateProvider.selectedDate);
                                                  final checkBoxConsumer = Provider.of<CheckBoxMainCategoryConsumer>(context, listen: false);
                                                  final checkBoxList = checkBoxConsumer.checkBoxMap[currentDateStr] ?? [];
                                                  final newIndex = checkBoxList.length - 1;
                                                  checkBoxList.add(CheckBoxData(index: newIndex, url: url, docId: newLinkDocId, isChecked: false));
                                                  checkBoxConsumer.updateCheckBoxList(currentDateStr, newIndex, url, newLinkDocId);

// Set all checkboxes to false except for the newly added one
                                                  for (int i = 0; i < checkBoxList.length; i++) {
                                                    if (i == newIndex) {
                                                      checkBoxConsumer.updateCheckBoxList(currentDateStr, i, checkBoxList[i].url, checkBoxList[i].docId);
                                                    }
                                                  }
                                                  Navigator.pop(
                                                      context);
                                                });
                                              } catch (e) {
                                                addRecentLinkNoteController.clear();
                                                addRecentLinkController.clear();
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
                                                .instance.collection(corporationEmail).doc(corporationEmail).collection(roll);

                                            List<String> readBy =
                                            [];
                                            // readBy.add(FirebaseAuth.instance.currentUser!.uid);
                                            DocumentReference
                                            newLinkDoc =
                                            await recentLinksCollection.add({
                                              'senderUid':
                                              FirebaseAuth.instance.currentUser!.uid,
                                              'url': url,
                                              'date': formattedSelectedDate,
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
                                              addRecentLinkNoteController.clear();
                                              addRecentLinkController.clear();
                                              final dateProvider = Provider.of<DateProvider>(context, listen: false);
                                              final currentDateStr = dateFormat.format(dateProvider.selectedDate);
                                              final checkBoxConsumer = Provider.of<CheckBoxMainCategoryConsumer>(context, listen: false);
                                              final checkBoxList = checkBoxConsumer.checkBoxMap[currentDateStr] ?? [];
                                              final newIndex = checkBoxList.length - 1;
                                              checkBoxList.add(CheckBoxData(index: newIndex, url: url, docId: newLinkDocId, isChecked: false));
                                              checkBoxConsumer.updateCheckBoxList(currentDateStr, newIndex, url, newLinkDocId);

// Set all checkboxes to false except for the newly added one
                                              for (int i = 0; i < checkBoxList.length; i++) {
                                                if (i == newIndex) {
                                                  checkBoxConsumer.updateCheckBoxList(currentDateStr, i, checkBoxList[i].url, checkBoxList[i].docId);
                                                }
                                              }
                                              Navigator.pop(context);
                                            });
                                          } catch (e) {
                                            addRecentLinkNoteController.clear();
                                            addRecentLinkController.clear();
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
              margin: EdgeInsets.symmetric(horizontal: 10*fontSizeProvider.fontSizeMultiplier, vertical: 10*fontSizeProvider.fontSizeMultiplier),
              width: 310*fontSizeProvider.fontSizeMultiplier,
              height: 40*fontSizeProvider.fontSizeMultiplier,
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
          )):Container()
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

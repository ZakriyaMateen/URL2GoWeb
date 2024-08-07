import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MetaDataFetch/MetaData.dart';
import '../Properties/Colors.dart';
import '../Properties/fontSizes.dart';
import '../Properties/fontWeights.dart';
import '../Providers/CategoryProvider.dart';
import '../Providers/FontSizeProvider.dart';
import '../Providers/recentLinksTabProvider.dart';
import '../Providers/searchProvider.dart';
import '../Utils/PdfPrint.dart';
import '../Utils/shareDialog.dart';
import '../Utils/text.dart';


final noteFormKey = GlobalKey<FormState>();
TextEditingController noteController = TextEditingController();
Widget recentLinksMainCategorySearch(double w,double h,String roll,CategoryProvider categoryProvider,FontSizeProvider fontSizeProvider, String profileImageUrl,String firstName,String lastName,String searchText,BuildContext context,String corporationEmail){
  SearchProvider searchProvider = Provider.of<SearchProvider>(context);

  return Padding(
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
              textRubik('Search', textColor, w500, size18*fontSizeProvider.fontSizeMultiplier),
            ],
          ),
          SizedBox(
            height: 10,
          ),
  
          Container(
              width:fontSizeProvider.fontSizeMultiplier<=1? 330:330*fontSizeProvider.fontSizeMultiplier,
              height: fontSizeProvider.fontSizeMultiplier<=1?h * 0.65:h*0.65*fontSizeProvider.fontSizeMultiplier,
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(10)
              ),
              margin: EdgeInsets.only(top: 10),
              child:

//continue from here

              Consumer<RecentLinksTabProvider>(builder:
                  (context, recentLinksTabProvider, _) {
                return StreamBuilder<

                    QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: textRoboto('Select a Category',
                              textColor, w400, size13*fontSizeProvider.fontSizeMultiplier),
                        );
                      } else {
                        List docs = snapshot.data!.docs;

// Function to parse date and time strings into DateTime

                        docs = docs
                            .where((doc) =>
                        (doc['metaData'] as String).toLowerCase().contains(searchProvider.searchText.toLowerCase())
                            ||
                            (doc['url'] as String).toLowerCase().contains(searchProvider.searchText.toLowerCase())
                        )
                            .toList();

                        return ListView.builder(
                          itemBuilder: (context, index) {
                            // final data = docs[index].data();
                            final data = docs[index].data();

                            return Container(
                              width: w,
                              height: fontSizeProvider.fontSizeMultiplier<=1?120:120*fontSizeProvider.fontSizeMultiplier,
                              padding: EdgeInsets.only(
                                  left: 10*fontSizeProvider.fontSizeMultiplier, right: 10*fontSizeProvider.fontSizeMultiplier),
                              margin: EdgeInsets.only(
                                  top: 5*fontSizeProvider.fontSizeMultiplier, bottom: 5*fontSizeProvider.fontSizeMultiplier),
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
                                          size10*fontSizeProvider.fontSizeMultiplier),
                                      SizedBox(
                                        width: 5*fontSizeProvider.fontSizeMultiplier,
                                      ),
                                      //next line is constant
                                      textRubik('/', textColor,
                                          w400, size10*fontSizeProvider.fontSizeMultiplier),
                                      SizedBox(
                                        width: 5*fontSizeProvider.fontSizeMultiplier,
                                      ),
                                      textRubik(
                                          data!['time'],
                                          textColor,
                                          w400,
                                          size10*fontSizeProvider.fontSizeMultiplier),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5*fontSizeProvider.fontSizeMultiplier,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: fontSizeProvider.fontSizeMultiplier<=1?250:250*fontSizeProvider.fontSizeMultiplier,
                                        child: GestureDetector(
                                            onTap: () async {
                                              _launchUrl(
                                                  data['url']);
                                              try {
                                                DocumentReference docRef = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).doc(data['docId']);
                                                DocumentSnapshot readBySnap = await docRef.get();
                                                List<dynamic> readByList = readBySnap.get('readBy');
                                                readByList.add(FirebaseAuth.instance.currentUser!.uid);

                                                await docRef.update({
                                                  'readBy':FieldValue.arrayUnion(readByList)
                                                }).then((value) {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Marked as read!')));
                                                });

                                              } catch (e) {
                                                print(e);
                                              }
                                            },
                                            child: textLink(
                                                (data['url'] == data['metaData']) ||
                                                    data['metaData'] == 'Empty'
                                                    ? data['url'].toString().length>54?data['url'].toString().substring(0,50):data['url']
                                                    : data['metaData'].toString().length>54?data['metaData'].toString().substring(0,50):data['metaData'],
                                                textColor,
                                                w500,
                                                size16*fontSizeProvider.fontSizeMultiplier)),
                                      ),
                                      GestureDetector(
                                        onTap: ()async{
                                          try{
                                            String note = await data['note'];
                                            String docId = await data['docId'];
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
                                                      key: noteFormKey,
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
                                                            controller: noteController,
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
                                                                  if(noteFormKey.currentState!.validate()){
                                                                    noteFormKey.currentState!.save();
                                                                    try{
                                                                      FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(roll).doc(docId).update(
                                                                          {'note':noteController.text.toString()}).then((value) {
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
                                          }
                                          catch(e){
                                            Fluttertoast.showToast(msg: 'No note saved for this url!');
                                            print(e.toString());
                                          }

                                        },
                                        child: Container(
                                          width: 40*fontSizeProvider.fontSizeMultiplier,
                                          height: 40*fontSizeProvider.fontSizeMultiplier,
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
                                              width: 15*fontSizeProvider.fontSizeMultiplier,
                                              height: 15*fontSizeProvider.fontSizeMultiplier,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10*fontSizeProvider.fontSizeMultiplier,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Builder(builder:
                                          (BuildContext context) {
                                        return InkWell(
                                          onTap: () async {
                                            shareUrl=data['url'];
                                            showCustomDialog(context);
                                          },
                                          child: Container(
                                            constraints:
                                            BoxConstraints(
                                                maxHeight: 22*fontSizeProvider.fontSizeMultiplier,
                                                minWidth: 60*fontSizeProvider.fontSizeMultiplier),
                                            padding: EdgeInsets
                                                .symmetric(
                                                horizontal: 4*fontSizeProvider.fontSizeMultiplier,
                                                vertical: 3*fontSizeProvider.fontSizeMultiplier),
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
                                                  size12*fontSizeProvider.fontSizeMultiplier),
                                            ),
                                          ),
                                        );
                                      }),
                                      SizedBox(
                                        width: 10*fontSizeProvider.fontSizeMultiplier,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          try {
                                            await createPDF(
                                                data['url'])
                                                .then((value) {
                                              // print('saved');
                                            });
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        },
                                        child: Container(
                                          constraints:
                                          BoxConstraints(
                                              maxHeight: 22*fontSizeProvider.fontSizeMultiplier,
                                              minWidth: 60*fontSizeProvider.fontSizeMultiplier),
                                          padding: EdgeInsets
                                              .symmetric(
                                              horizontal: 4*fontSizeProvider.fontSizeMultiplier,
                                              vertical: 3*fontSizeProvider.fontSizeMultiplier),
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
                                                size12*fontSizeProvider.fontSizeMultiplier),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10*fontSizeProvider.fontSizeMultiplier,
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
                                                            .instance.collection(corporationEmail).doc(corporationEmail)
                                                            .collection(
                                                            roll)
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
                                              maxHeight: 22*fontSizeProvider.fontSizeMultiplier,
                                              minWidth: 60*fontSizeProvider.fontSizeMultiplier),
                                          padding: EdgeInsets
                                              .symmetric(
                                              horizontal: 4*fontSizeProvider.fontSizeMultiplier,
                                              vertical: 3*fontSizeProvider.fontSizeMultiplier),
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
                                                size12*fontSizeProvider.fontSizeMultiplier),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10*fontSizeProvider.fontSizeMultiplier,
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

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url),
  )) {
    throw Exception('Could not launch $url');
  }
}
DateTime parseDateTime(String date, String time) {
  // Assuming the date format is "dd MMM yyyy" and time format is "hh:mma"
  String formattedDateTimeString = '$date $time';

  // Specify the date and time format used in your strings
  final format = DateFormat('dd MMM yyyy hh:mma');

  // Parse the formatted string into a DateTime object
  return format.parse(formattedDateTimeString);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url2goweb/Providers/FontSizeProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Providers/CategoryProvider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../MetaDataFetch/MetaData.dart';
import '../Properties/Colors.dart';
import '../Properties/fontSizes.dart';
import '../Properties/fontWeights.dart';
import '../Providers/recentLinksTabProvider.dart';
import '../Utils/PdfPrint.dart';
import '../Utils/shareDialog.dart';
import '../Utils/text.dart';

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


final noteFormKey = GlobalKey<FormState>();
TextEditingController noteController = TextEditingController();
Widget recentLinksSubCategory(double w,double h,String roll,CategoryProvider categoryProvider,FontSizeProvider fontSizeProvider, String profileImageUrl,String firstName,String lastName,String mySublistDocId,String corporationEmail){
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
              textRubik('Recent links', textColor, w500, size18),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 296 * fontSizeProvider.fontSizeMultiplier,
            height: 40* fontSizeProvider.fontSizeMultiplier,
            margin: EdgeInsets.only(left: 2 * fontSizeProvider.fontSizeMultiplier, right: 2 * fontSizeProvider.fontSizeMultiplier),
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
                  width: 10 * fontSizeProvider.fontSizeMultiplier,
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
                            horizontal: 4 * fontSizeProvider.fontSizeMultiplier, vertical: 3 * fontSizeProvider.fontSizeMultiplier),
                        constraints: BoxConstraints(
                            maxHeight: 20 * fontSizeProvider.fontSizeMultiplier, minWidth: 40 * fontSizeProvider.fontSizeMultiplier),
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
                              size12 * fontSizeProvider.fontSizeMultiplier),
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
                            maxHeight: 20 * fontSizeProvider.fontSizeMultiplier, minWidth: 40 * fontSizeProvider.fontSizeMultiplier),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4 * fontSizeProvider.fontSizeMultiplier, vertical: 3 * fontSizeProvider.fontSizeMultiplier),
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
                              size12*fontSizeProvider.fontSizeMultiplier),
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
                            maxHeight: 20 * fontSizeProvider.fontSizeMultiplier, minWidth: 40 * fontSizeProvider.fontSizeMultiplier),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4 * fontSizeProvider.fontSizeMultiplier, vertical: 3 * fontSizeProvider.fontSizeMultiplier),
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
                              size12*fontSizeProvider.fontSizeMultiplier),
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
              width: fontSizeProvider.fontSizeMultiplier<=1? 330:330*fontSizeProvider.fontSizeMultiplier,
              height: fontSizeProvider.fontSizeMultiplier<=1?h * 0.65:h*0.65*fontSizeProvider.fontSizeMultiplier,
              margin: EdgeInsets.only(top: 10),
              child:

//continue from here

              Consumer<RecentLinksTabProvider>(builder:
                  (context, recentLinksTabProvider, _) {
                return StreamBuilder<

                    QuerySnapshot<Map<String, dynamic>>>(
                  // stream: FirebaseFirestore.instance
                  //     .collection(roll)
                  // .doc(categoryProvider.title)
                  //     .collection('RecentLinks')
                  //     .snapshots(),
                    stream: FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId).snapshots(),
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

                        if (recentLinksTabProvider
                            .allUnreadNew[0]) {
                          // print('0');
                          // docs = docs;
                        } else if (recentLinksTabProvider
                            .allUnreadNew[1]) {
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
                              // height: 110,
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
                                          size10*fontSizeProvider.fontSizeMultiplier),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      //next line is constant
                                      textRubik('/', textColor,
                                          w400, size10*fontSizeProvider.fontSizeMultiplier),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      textRubik(
                                          data!['time'],
                                          textColor,
                                          w400,
                                          size10*fontSizeProvider.fontSizeMultiplier),
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
                                        width: 250*fontSizeProvider.fontSizeMultiplier,
                                        child: GestureDetector(
                                            onTap: () async {
                                              _launchUrl(
                                                  data['url']);
                                              try {
                                                 DocumentSnapshot snap = await  FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId).doc(data['docId']).get();

                                                List<dynamic> readBy = snap['readBy'];

                                                readBy.add(FirebaseAuth.instance.currentUser!.uid);

                                                DocumentReference ref = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId).doc(data['docId']);

                                                await ref.update({'readBy': FieldValue.arrayUnion(readBy)
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
                                                                      FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection(mySublistDocId).doc(docId).update(
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
                                          width: 40 * fontSizeProvider.fontSizeMultiplier,
                                          height: 40 * fontSizeProvider.fontSizeMultiplier,
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
                                              width: 15* fontSizeProvider.fontSizeMultiplier,
                                              height: 15* fontSizeProvider.fontSizeMultiplier,
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
                                            shareUrl=data['url'];
                                            showCustomDialog(context);


                                          },
                                          child: Container(
                                            constraints:
                                            BoxConstraints(
                                                maxHeight: 22 * fontSizeProvider.fontSizeMultiplier,
                                                minWidth: 60 * fontSizeProvider.fontSizeMultiplier),
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
                                                  size12 * fontSizeProvider.fontSizeMultiplier),
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
                                              // print('saved');
                                            });
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        },
                                        child: Container(
                                          constraints:
                                          BoxConstraints(
                                              maxHeight: 22 * fontSizeProvider.fontSizeMultiplier,
                                              minWidth: 60 * fontSizeProvider.fontSizeMultiplier),
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
                                                size12* fontSizeProvider.fontSizeMultiplier),
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
                                                            .instance.collection(corporationEmail).doc(corporationEmail)
                                                            .collection(mySublistDocId)
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
  );
}
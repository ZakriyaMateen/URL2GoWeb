// Widget messagesContainer(double w, double h) {
//   String chatReceiverProfileImage = '';
//   String chatReceiverUsername = '';
//   String chatReceiverRoll = '';
//   String chatDocId = '';
//   String chatReceiverUid = '';
//   String isRequestMessage = '';
//   FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(context,listen: false);
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [textRubik('Messages', textColor, w500, size28*fontSizeProvider.fontSizeMultiplier)],
//       ),
//       const SizedBox(
//         height: 15,
//       ),
//       Stack(
//         children: [
//           Container(
//               width: 330,
//               height: h * 0.74,
//               decoration: BoxDecoration(
//                 color: white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                   stream: FirebaseFirestore.instance
//                       .collection('Chats')
//                       .where('senderUid',
//                       isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                       .snapshots(),
//                   builder: (context, receiverSnapshot) {
//                     if (receiverSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     } else if (receiverSnapshot.hasError) {
//                       print(receiverSnapshot.error);
//                       return Center(
//                         child: textRoboto('Error loading messages', textColor,
//                             w400, size16*fontSizeProvider.fontSizeMultiplier),
//                       );
//                     } else {
//                       // final messagesDocs = snapshot.data!.docs;
//
//                       return StreamBuilder<
//                           QuerySnapshot<Map<String, dynamic>>>(
//                           stream: FirebaseFirestore.instance
//                               .collection('Chats')
//                           // .where('senderUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                               .where('receiverUid',
//                               isEqualTo:
//                               FirebaseAuth.instance.currentUser!.uid)
//                               .snapshots(),
//                           builder: (context, senderSnapshot) {
//                             if (senderSnapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             } else if (senderSnapshot.hasError) {
//                               return Center(
//                                 child: textRoboto('Error loading messages',
//                                     textColor, w400, size16*fontSizeProvider.fontSizeMultiplier),
//                               );
//                             } else {
//                               // final messagesDocs = snapshot.data!.docs;
//                               final messagesDocs = [
//                                 ...receiverSnapshot.data!.docs,
//                                 ...senderSnapshot.data!.docs
//                               ];
//                               final filteredMessages =
//                               messagesDocs.where((data) {
//                                 String senderName = "${capitalizeFirstLetter(
//                                     data['firstNameSender'])} " +
//                                     data['lastNameSender'];
//                                 String receiverName = "${capitalizeFirstLetter(
//                                     data['firstNameReceiver'])} " +
//                                     data['lastNameReceiver'];
//                                 String roll = data['receiverUid'] ==
//                                     FirebaseAuth.instance.currentUser!.uid
//                                     ? data['rollSender']
//                                     : data['rollReceiver'].toString();
//
//                                 return senderName.toLowerCase().contains(
//                                     messageSearchText.toLowerCase()) ||
//                                     receiverName.toLowerCase().contains(
//                                         messageSearchText.toLowerCase()) ||
//                                     roll.toLowerCase().contains(
//                                         messageSearchText.toLowerCase());
//                               }).toList();
//
//                               return filteredMessages.isEmpty
//                                   ? Center(
//                                 child: Text(
//                                   'No matching messages found.',
//                                   style: TextStyle(
//                                       color: textColor,
//                                       fontSize: size16*fontSizeProvider.fontSizeMultiplier),
//                                 ),
//                               )
//                                   : ListView.builder(
//                                 itemBuilder: (context, index) {
//                                   // final data = messagesDocs[index].data();
//                                   final data =
//                                   filteredMessages[index].data();
//
//                                   return InkWell(
//                                     onTap: () async {
//                                       try {
//                                         //user_1=>user_2
//
//                                         chatReceiverProfileImage = data[
//                                         'receiverUid'] ==
//                                             FirebaseAuth.instance
//                                                 .currentUser!.uid
//                                             ? await data[
//                                         'profileImageSender']
//                                             : await data[
//                                         'profileImageReceiver'];
//                                         chatReceiverUsername = data[
//                                         'receiverUid'] ==
//                                             FirebaseAuth.instance
//                                                 .currentUser!.uid
//                                             ? "${capitalizeFirstLetter(data[
//                                         'firstNameSender'])} " +
//                                             data['lastNameSender']
//                                             : "${capitalizeFirstLetter(data[
//                                         'firstNameReceiver'])} " +
//                                             data[
//                                             'lastNameReceiver'];
//
//                                         chatReceiverRoll =
//                                         await data['rollReceiver'];
//
//                                         chatDocId = await data['docId'];
//                                         chatReceiverUid =
//                                         await data['receiverUid'];
//                                         isRequestMessage = data[
//                                         'isRequestMessage']
//                                             .toString();
//
//                                         navigateWithTransition(
//                                             context,
//                                             Messenger(
//                                                 globalChatReceiverProfileImage:
//                                                 chatReceiverProfileImage,
//                                                 globalchatReceiverUsername:
//                                                 chatReceiverUsername,
//                                                 globalchatReceiverRoll:
//                                                 chatReceiverRoll,
//                                                 globalchatDocId:
//                                                 chatDocId,
//                                                 globalchatReceiverUid:
//                                                 chatReceiverUid,
//                                                 globalisRequestMessage:
//                                                 isRequestMessage
//                                                     .toString()),
//                                             TransitionType.fade);
//                                       } catch (e) {
//                                         print(e.toString());
//                                         Fluttertoast.showToast(
//                                             msg:
//                                             'Cannot contact right now!');
//                                       }
//                                     },
//                                     child: Container(
//                                       margin: EdgeInsets.only(top: 10),
//                                       width: 330,
//                                       height: 70,
//                                       child: Column(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                         children: [
//                                           Padding(
//                                             padding:
//                                             EdgeInsets.symmetric(
//                                                 horizontal: 14),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .spaceBetween,
//                                               crossAxisAlignment:
//                                               CrossAxisAlignment
//                                                   .center,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     Container(
//                                                       width: 40,
//                                                       height: 40,
//                                                       child: ClipRRect(
//                                                           borderRadius:
//                                                           BorderRadius
//                                                               .circular(
//                                                               10),
//                                                           child: Image
//                                                               .network(
//                                                             data['receiverUid'] ==
//                                                                 FirebaseAuth
//                                                                     .instance.currentUser!.uid
//                                                                 ? data[
//                                                             'profileImageSender']
//                                                                 : data[
//                                                             'profileImageReceiver'],
//                                                             fit: BoxFit
//                                                                 .cover,
//                                                           )),
//                                                     ),
//                                                     SizedBox(
//                                                       width: 10,
//                                                     ),
//                                                     Column(
//                                                       mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .center,
//                                                       crossAxisAlignment:
//                                                       CrossAxisAlignment
//                                                           .start,
//                                                       children: [
//                                                         textRoboto(
//                                                             data['receiverUid'] ==
//                                                                 FirebaseAuth
//                                                                     .instance.currentUser!.uid
//                                                                 ? "${capitalizeFirstLetter(data['firstNameSender'])} " +
//                                                                 data[
//                                                                 'lastNameSender']
//                                                                 : "${capitalizeFirstLetter(data['firstNameReceiver'])} " +
//                                                                 data['lastNameReceiver'],
//                                                             // chatReceiverUid,
//                                                             textColor,
//                                                             w500,
//                                                             size16*fontSizeProvider.fontSizeMultiplier),
//                                                         SizedBox(
//                                                           height: 1.5,
//                                                         ),
//                                                         textRoboto(
//                                                             data['receiverUid'] ==
//                                                                 FirebaseAuth
//                                                                     .instance.currentUser!.uid
//                                                                 ? data[
//                                                             'rollSender']
//                                                                 : data['rollReceiver']
//                                                                 .toString(),
//                                                             textColor,
//                                                             w400,
//                                                             size14*fontSizeProvider.fontSizeMultiplier)
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 // Container(
//                                                 //     width: 20,
//                                                 //   height: 20,
//                                                 //   decoration: BoxDecoration(
//                                                 //     color: yellow,
//                                                 //     shape: BoxShape.circle
//                                                 //   ),
//                                                 //   child: Center(
//                                                 //     child: textRoboto(messagesList[index]['unreadMessages'], darkGrey, w400,size10),
//                                                 //   ),
//                                                 // )
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 7,
//                                           ),
//                                           Divider(
//                                             color: pageBackgroundColor,
//                                             thickness: 1,
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 itemCount: filteredMessages.length,
//                                 physics: ClampingScrollPhysics(),
//                               );
//                             }
//                           });
//                     }
//                   })),
//           Positioned(
//               bottom: 0,
//               child: Container(
//                 width: 330,
//                 height: 70,
//                 decoration: BoxDecoration(
//                     color: white, borderRadius: BorderRadius.circular(10)),
//                 child: Container(
//                   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   width: 310,
//                   height: 40,
//                   decoration: BoxDecoration(
//                       color: offWhite,
//                       borderRadius: BorderRadius.circular(10)),
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.only(left: 10),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Flexible(
//                         child: TextFormField(
//                           onChanged: (v) {
//                             setState(() {
//                               searchText = v;
//                             });
//                           },
//                           style: GoogleFonts.roboto(
//                             textStyle: TextStyle(
//                                 color: textColor,
//                                 letterSpacing: .5,
//                                 fontWeight: w400,
//                                 fontSize: size14*fontSizeProvider.fontSizeMultiplier),
//                           ),
//                           cursorColor: textColor,
//                           decoration: InputDecoration.collapsed(
//                             hintText: 'Search message or link',
//                             hintStyle: GoogleFonts.roboto(
//                               textStyle: TextStyle(
//                                   color: textColorLight,
//                                   letterSpacing: .5,
//                                   fontWeight: w400,
//                                   fontSize: size14*fontSizeProvider.fontSizeMultiplier),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ))
//         ],
//       ),
//     ],
//   );
// }

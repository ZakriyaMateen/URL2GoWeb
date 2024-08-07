// StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
// stream: FirebaseFirestore.instance.collection('Chats')
// // .where('senderUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
// .where('receiverUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
// .snapshots(),
// builder: (context, senderSnapshot) {
// if (senderSnapshot.connectionState == ConnectionState.waiting) {
// return const Center(
// child: CircularProgressIndicator(),
// );
// } else if (senderSnapshot.hasError) {
// return Center(
// child: textRoboto('Error loading messages', textColor, w400, size16),
// );
// } else {
//
// // final messagesDocs = snapshot.data!.docs;
// final messagesDocs = [...receiverSnapshot.data!.docs, ...senderSnapshot.data!.docs];
// return
//
// ListView.builder(itemBuilder: (context,index){
// final data = messagesDocs[index].data();
// return InkWell(
//
// onTap:()async{
// data['receiverUid'] == FirebaseAuth.instance.currentUser!.uid?
// chatReceiverProfileImage=await data['profileImageSender']:
// chatReceiverProfileImage=await data['profileImageReceiver'];
//
//
// chatReceiverUsername=
//
// data['receiverUid'] == FirebaseAuth.instance.currentUser!.uid?
// '${capitalizeFirstLetter(await data['firstNameSender'])} ${capitalizeFirstLetter(await data['lastNameSender'])}':
// '${capitalizeFirstLetter(await data['firstNameReceiver'])} ${capitalizeFirstLetter(await data['lastNameReceiver'])}';
// chatReceiverRoll=await data['rollReceiver'];
// chatDocId=await data['docId'];
// chatReceiverUid=await data['receiverUid'];
// isRequestMessage=await data['isRequestMessage'].toString();
//
// setState(() {
// globalChatReceiverProfileImage=chatReceiverProfileImage;
// globalchatReceiverUsername=chatReceiverUsername;
// globalchatReceiverRoll=chatReceiverRoll;
// globalchatDocId=chatDocId;
// globalchatReceiverUid=chatReceiverUid;
// globalisRequestMessage=isRequestMessage;
// });
// },
// child: Container(
// margin: EdgeInsets.only(top: 10),
// width: 330,
// height: 70,
// child: Column(
// mainAxisAlignment: MainAxisAlignment.center,
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Padding(
// padding: EdgeInsets.symmetric(horizontal: 14),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Row(
// children: [
// Container(
// width: 40,
// height: 40,
// child: ClipRRect(
// borderRadius: BorderRadius.circular(10),
// child: Image.network(
// data['receiverUid'] == FirebaseAuth.instance.currentUser!.uid?
// data['profileImageSender']
//     :data['profileImageReceiver'],fit: BoxFit.cover,)),
// ),
// SizedBox(width:10,),
// Column(
// mainAxisAlignment: MainAxisAlignment.center,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
//
// textRoboto(
// data['receiverUid'] == FirebaseAuth.instance.currentUser!.uid?
// capitalizeFirstLetter(data['firstNameSender'])+" "+data['lastNameSender']:
// capitalizeFirstLetter(data['firstNameReceiver'])+" "+data['lastNameReceiver'],
// // chatReceiverUid,
// textColor, w500, size16),
// SizedBox(height: 1.5,),
//
// textRoboto(
//
// data['receiverUid'] == FirebaseAuth.instance.currentUser!.uid?
// data['rollSender']:
// data['rollReceiver'].toString(), textColor, w400, size14)
// ],
// ),
// ],
// ),
// // Container(
// //     width: 20,
// //   height: 20,
// //   decoration: BoxDecoration(
// //     color: yellow,
// //     shape: BoxShape.circle
// //   ),
// //   child: Center(
// //     child: textRoboto(messagesList[index]['unreadMessages'], darkGrey, w400,size10),
// //   ),
// // )
// ],
// ),
// ),
// SizedBox(height: 7,),
// Divider(
// color: pageBackgroundColor,
// thickness: 1,
// )
// ],
// ),
// ),
// );
// },itemCount: messagesDocs.length,physics: ClampingScrollPhysics(),);
//
//
//
// }})
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnreadMessagesDashboardProvider extends ChangeNotifier{

  List<String> allPeopleUnreadMessagesList = [];
  List<Map<String,dynamic>> uid_unread = [];
  void resetIndexToZeroUnread(int index,String uid){
    uid_unread[index][uid]='0';
    notifyListeners();
  }
  void reset(){
    allPeopleUnreadMessagesList.clear();
    uid_unread.clear();
    notifyListeners();
  }

   getAllPeopleUnreadMessages(List allUsersUids,String corporationEmail)async{
    try{
      DocumentSnapshot unread = await FirebaseFirestore.instance.collection(corporationEmail).doc(corporationEmail).collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).get();

      for(String uid in allUsersUids){
        try{
          allPeopleUnreadMessagesList.add(unread[uid]);
        }
        catch(e){
          allPeopleUnreadMessagesList.add('0');
        }
      }
      notifyListeners();

      set_uid_unread(allUsersUids);
      notifyListeners();


    }
    catch(e){
      print(e.toString());
    }
  }

  void set_uid_unread(List allUsersUids){
      for(int i=0;i<allUsersUids.length;i++){
        uid_unread.add({
          allUsersUids[i]:allPeopleUnreadMessagesList[i]
        });
      }
      // print(uid_unread);
      notifyListeners();


  }

}
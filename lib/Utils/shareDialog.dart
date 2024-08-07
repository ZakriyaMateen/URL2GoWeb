import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url2goweb/Providers/ShareOptionsProvider.dart';
import 'package:url2goweb/Providers/shareListProvider.dart';
import 'package:url2goweb/Utils/text.dart';

import '../Properties/Colors.dart';
import '../Properties/fontSizes.dart';
import '../Properties/fontWeights.dart';
String shareUrl='';

class ShareDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      insetAnimationCurve:Curves.bounceInOut,
      backgroundColor: Colors.transparent,
      child: dialogContent(context,shareUrl),
    );
  }

  Widget dialogContent(BuildContext context,String url) {
    return Container(
      constraints: BoxConstraints(minWidth: 400,maxWidth: 400,minHeight: 300,maxHeight: 300),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          textRubik(            'Choose Sharing Option',  textColor,w500, size28),
          SizedBox(height: 24.0),
          buildOption(context, 'Share via Email', Icons.email, Colors.blue,url),
          SizedBox(height: 16.0),
          buildOption(context, 'Share via Contacts', Icons.contacts, Colors.green,url),
        ],
      ),
    );
  }

  Widget buildOption(BuildContext context, String text, IconData icon, Color color,String url) {
    ShareOptionsProvider shareOptionsProvider = Provider.of<ShareOptionsProvider>(context);
    ShareListProvider shareListProvider = Provider.of<ShareListProvider>(context,listen: false);
    return Padding(
      padding:  EdgeInsets.only(left: 40),
      child: GestureDetector(
        onTap: () {

          // Perform action based on the selected option
          if (text == 'Share via Email') {
            // Handle share via email action
            try {
              _onShare(context,
                 url);
            } catch (error) {
              print(error
                  .toString());
            }

            Navigator.pop(context); // Close the dialog
          } else if (text == 'Share via Contacts') {
            // Handle share via contacts action
            shareListProvider.setSharingUrl(url);
            shareOptionsProvider.update('contact');

            Navigator.pop(context); // Close the dialog
          }
        },
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: color,
              size: 32.0,
            ),
            SizedBox(width: 16.0),
            textRubik(
                text,  textColor  ,w500, size18),

          ],
        ),
      ),
    );
  }
}
_onShare(BuildContext context, String text) async {
  final box = context.findRenderObject() as RenderBox?;

  await Share.share(
    text,
    subject: "-- I am Sharing this Link -- $text",
    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  );
}

void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ShareDialog();
    },
  );
}
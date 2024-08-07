import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url2goweb/Providers/DateProvider.dart';
import 'package:url2goweb/Providers/FontSizeProvider.dart';
import 'package:url2goweb/Providers/ShareListProviderMultiple.dart';
import 'package:url2goweb/Providers/ShareListProviderMultipleMainCategory.dart';
import 'package:url2goweb/Providers/ShareOptionsProviderSublist.dart';
import 'package:url2goweb/Providers/SublistNameEditProvider.dart';
import 'package:url2goweb/Providers/UnreadMessagesDashboardProvider.dart';
import 'package:url2goweb/Providers/recentLinksTabProvider.dart';
import 'package:url2goweb/Providers/searchProvider.dart';
import 'package:url2goweb/Providers/shareListProvider.dart';
import 'package:url2goweb/Providers/shareListProviderSublist.dart';
import 'package:url2goweb/Screens/AuthScreens/CorpLogin.dart';
import 'package:url2goweb/Screens/AuthScreens/LoginScreen.dart';
import 'package:url2goweb/Screens/AuthScreens/LoginScreenUser.dart';
import 'package:url2goweb/Screens/AuthScreens/SignUpScreenCorp.dart';
import 'package:url2goweb/Screens/AuthScreens/SignupScreen.dart';
import 'package:url2goweb/Screens/Dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url2goweb/Utils/CalendarWidget.dart';
import 'package:url2goweb/Utils/transitions.dart';
import 'Providers/CategoryProvider.dart';
import 'Providers/CategoryProviderMessenger.dart';
import 'Providers/CheckBoxConsumer.dart';
import 'Providers/ContactSearchProvider.dart';
import 'Providers/ShareOptionsDailyLinksMainCategoryProvider.dart';
import 'Providers/ShareOptionsDailyLinksProvider.dart';
import 'Providers/ShareOptionsProvider.dart';
import 'Providers/ShowHideSublistProvider.dart';
import 'Providers/checkBoxMainCategoryConsumer.dart';
import 'Screens/AuthScreens/AdminScreen/UsersRequests.dart';
import 'Screens/AuthScreens/EmployeeLogin.dart';
import 'Screens/Dashboard2.dart';
import 'Screens/Messenger.dart';
import 'Screens/SplashScreen/AnimatedSplashScreen.dart';
import 'firebase_options.dart';
// void main() {
//

// }


void main() async{

// ...
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // checkPersistence();
  }

  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecentLinksTabProvider()),
        ChangeNotifierProvider(create: (_) => DateProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CheckBoxConsumer()),
        ChangeNotifierProvider(create: (_ ) => CheckBoxMainCategoryConsumer()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProviderMessenger()),
        ChangeNotifierProvider(create: (_) => ShareOptionsProvider()),
        ChangeNotifierProvider(create: (_) => ShareListProvider()),
        ChangeNotifierProvider(create: (_) => ShareListProviderMultiple()),
        ChangeNotifierProvider(create: (_) => ShareListProviderMultipleMainCategory()),
        ChangeNotifierProvider(create: (_) => ShareOptionsDailyLinksProvider()),
        ChangeNotifierProvider(create: (_) => ShareOptionsDailyLinksMainCategoryProvider()),
        ChangeNotifierProvider(create: (_) => UnreadMessagesDashboardProvider()),
        ChangeNotifierProvider(create: (_) => ContactSearchProvider()),
        ChangeNotifierProvider(create: (_) => ShowHideSublistProvider()),
        ChangeNotifierProvider(create: (_) => ShareOptionsProviderSublist()),
        ChangeNotifierProvider(create: (_) => ShareListProviderSublist()),
        ChangeNotifierProvider(create: (_) => SublistNameEditProvider()),
      ],
      child:  MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'url2go',
        onGenerateRoute: (settings) {
          if (settings.name!.contains("/corp")) {
            // parse the URL and get the article ID here
            print('yes it contains');
            return MaterialPageRoute(
              builder: (context) => CorpLogin(),
            );
          }
          // Handle other routes if necessary
          return null; // Return null if the route is not handled
        },

        routes: {
          // '/': (context) => AnimatedSplashScreen(),
          '/corp': (context) => SignUpScreenCorp(),

        },
        home: AnimatedSplashScreen(),
      )
    );
  }
}
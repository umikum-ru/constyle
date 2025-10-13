import 'package:constyle/browser.dart';
import 'package:constyle/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

String pageForOpenFromNotify = "";
Stream<String>? _tokenStream;
RemoteMessage? lastMessage;
var newMessageReceive = 1.obs;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  dprint('Handling a background message ${message.messageId}');
//  FlutterAppBadger.updateBadgeCount(1);

  // WidgetsFlutterBinding.ensureInitialized();
  // //await Firebase.initializeApp();
  //
  // channel = const AndroidNotificationChannel(
  //   'high_importance_channel', // id
  //   'High Importance Notifications',// description
  //   importance: Importance.high,
  // );
  //
  // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  //
  // flutterLocalNotificationsPlugin.show(
  //     1,
  //     // notification.hashCode,
  //     message.data["title"],
  //     message.data["body"],
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         icon: 'launch_background',
  //       ),
  //     ));
  //
  // var prefs = await SharedPreferences.getInstance();
  // prefs.setString("notifyOpenpage", "");
  // var t = message.data["openpage"];
  // if (t != null){
  //   var t1 = message.data["openpage"].toString();
  //   if (t1.isNotEmpty) {
  //     dprint("_firebaseMessagingBackgroundHandler openpage=$t1");
  //     prefs.setString("notifyOpenpage", t1);
  //   }
  // }

}

var notifyToken = "".obs;

void _setToken(String? token) {
  if (token == null)
    return;
  dprint("notify token=$token");
  notifyToken.value = token;
}

firebaseInitApp() async {
  // var supported = await FlutterAppBadger.isAppBadgeSupported();
  // dprint("FlutterAppBadger supported=$supported");
  // FlutterAppBadger.removeBadge();
  dprint("_firebaseGetToken");
  await _firebaseGetToken();

  // if (!kIsWeb)
  channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications',// description
      importance: Importance.high,
    );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.cancelAll(); // Cancelling/deleting all notifications

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    dprint("FirebaseMessaging.getInitialMessage $message");
    if (message != null && message.notification != null) {
      // dprint("getInitialMessage $message");
      lastMessage = message;
      newMessageReceive.value++;
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
      var t = message.data["openpage"];
      if (t != null){
        var t1 = message.data["openpage"].toString();
        if (t1.isNotEmpty) {
          pageForOpenFromNotify = t1;
        }
      }
    }
  });
}

_firebaseGetToken() async {
  // dprint ("Firebase messaging: _getToken");

  // iOS
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //dprint('User granted permission: ${settings.authorizationStatus}');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Create an Android Notification Channel.
  //
  // We use this channel in the `AndroidManifest.xml` file to override the
  // default FCM channel to enable heads up notifications.
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  // Update the iOS foreground notification presentation options to allow
  // heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // await Future.delayed(Duration(seconds: 1));

  // Future.delayed(const Duration(milliseconds: 2000), () async {
  //   String? token = await FirebaseMessaging.instance.getAPNSToken();
    _setToken(await FirebaseMessaging.instance.getToken());
  // });

  // String? token = await FirebaseMessaging.instance.getAPNSToken();

  _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
  _tokenStream!.listen(_setToken);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    dprint("FirebaseMessaging.onMessageOpenedApp $message");
    if (message.notification == null)
      return;
    if (_lastMessageId != null)
      if (_lastMessageId == message.messageId)
        return;
    _lastMessageId = message.messageId;
    // FlutterAppBadger.updateBadgeCount(1);
    lastMessage = message;
    // user.fromOpenApp = true;
    newMessageReceive.value++;
    var t = message.data["openpage"];
    if (t != null){
      var t1 = message.data["openpage"].toString();
      if (t1.isNotEmpty) {
        openBrowser(t1);
        pageForOpenFromNotify = t1;
      }
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    dprint("FirebaseMessaging.onMessage $message");
    if (_lastMessageId != null)
      if (_lastMessageId == message.messageId)
        return;
    _lastMessageId = message.messageId;
    // FlutterAppBadger.updateBadgeCount(1);
    lastMessage = message;
    // user.fromOpenApp = false;
    newMessageReceive.value++;
    dprint('A new onMessageOpenedApp event was published!');
    var t = message.data["openpage"];
    if (t != null){
      var t1 = message.data["openpage"].toString();
      if (t1.isNotEmpty)
        openBrowser(t1);
    }

    // RemoteNotification? notification = message.notification;
    // RemoteNotification? notification = message.data;
    // AndroidNotification? android = message.notification?.android;
    // if (notification != null) { // && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
          1,
          // notification.hashCode,
          message.data["title"],
          message.data["body"],
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ));
    // }
  });
}

String? _lastMessageId;


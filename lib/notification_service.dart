import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camconnect/video_call_page.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey; // Add this

  NotificationService({required this.navigatorKey}); // Add this constructor

Future<void> initialize() async {
  print('[NotificationService] Initializing...');

  try {
    // Request permission for notifications
    print('[NotificationService] Requesting notification permissions...');
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('[NotificationService] Notification permissions granted.');

    // Get FCM token and store it
    print('[NotificationService] Getting FCM token...');
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('[NotificationService] Got FCM token: $token');
      await _storeFCMToken(token);
    } else {
      print('[NotificationService] Failed to get FCM token.');
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('[NotificationService] FCM token refreshed: $newToken');
      _storeFCMToken(newToken);
    });

    // Handle foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
  print("Foreground message received: ${message.notification}");

  if (message.data != null) {
    final type = message.data['type'] ?? ''; // Handle null case safely
    if (type == 'video_call') {
      print('Foreground Video Call: ${message.data}');
      final callerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(message.data['callerId'])
          .get();
      
      final callerName = callerDoc.data()?['username'] ?? 'Unknown';
      // Show your custom video call dialog
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => AlertDialog(
          title: Text('Incoming Video Call'),
          content: Text('$callerName is calling you'),
          actions: [
            TextButton(
              onPressed: () {
                // Accept call
                Navigator.pop(_); // Close the dialog
                // Navigate to call screen or handle it
             Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                    builder: (context) => VideoCallPage(
                      channelName: message.data['videoChannel'],
                      token: message.data['agoraToken'],
                    ),
                  ),
                );
              },
              child: Text('Accept'),
            ),
            TextButton(
  onPressed: () async {
    // Close the dialog
    Navigator.pop(_);

    // Send decline notification to the server
  },
  child: Text('Decline'),
)
          ],
        ),
      );
    }
  }
});


    // Handle when app is opened from a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        try {
          if (message.data['type'] == 'video_call') {
            final context = navigatorKey.currentContext;
            if (context != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallPage(
                    channelName: message.data['videoChannel'],
                    token: message.data['agoraToken'],
                  ),
                ),
              );
            }
          }
        } catch (e) {
          print('Error navigating to video call: $e');
        }
      });

     

    print('[NotificationService] Initialization complete.');
  } catch (e) {
    print('[NotificationService] Error during initialization: $e');
  }
}
  Future<void> _storeFCMToken(String token) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
    }
  }

Future<void> sendVideoCallNotification({
  required String receiverId,
  required String channelName,
  required String token,
}) async {
  try {
    // Get receiver's FCM token
    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    
    final receiverFCMToken = receiverDoc.data()?['fcmToken'];
    if (receiverFCMToken == null) {
      print('Receiver FCM token not found');
      return;
    }

    // Get caller's name (check if user is logged in)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in');
      return; // Or throw an error
    }
    final callerName = (await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get())
        .data()?['username'] ?? 'Someone';

    // Send FCM notification using Firebase Admin SDK on your server
    final response = await http.post(
      Uri.parse('http://192.168.1.5:5000/send_notification'), // Replace with your server endpoint
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'to': receiverFCMToken,  // Targeting receiver's FCM token directly
        'notification': {
          'title': 'Incoming Video Call',
          'body': '$callerName is calling you',
        },
        'data': {
          'type': 'video_call',
          'channelName': channelName,
          'token': token, // Agora token
          'callerId': user.uid,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification: ${response.body}');
    }

    print('Notification sent successfully!');
  } catch (e) {
    print('Error sending notification: $e');
  }
}


}
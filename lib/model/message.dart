import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receverId;
  String senderEmail;
  String message;
  Timestamp timestamp;
  Message({
    required this.message,
    required this.receverId,
    required this.senderEmail,
    required this.senderId,
    required this.timestamp,
  });
  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "receverId": receverId,
      "senderEmail": senderEmail,
      "message": message,
      "timestamp": timestamp,
    };
  }
}

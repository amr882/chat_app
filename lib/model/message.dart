class Message {
  String senderId;
  String receverId;
  String senderEmail;
  String message;
  int messageTime;
  Message({
    required this.message,
    required this.receverId,
    required this.senderEmail,
    required this.senderId,
    required this.messageTime,
  });
  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "receverId": receverId,
      "senderEmail": senderEmail,
      "message": message,
      "messageTime": messageTime,
    };
  }
}

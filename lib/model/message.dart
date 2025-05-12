class Message {
  String senderId;
  String receverId;
  String senderEmail;
  String message;
  int messageTime;
  String? photo;

  Message({
    required this.message,
    required this.receverId,
    required this.senderEmail,
    required this.senderId,
    required this.messageTime,
    this.photo,
  });
  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "receverId": receverId,
      "senderEmail": senderEmail,
      "message": message,
      "messageTime": messageTime,
      "photo": photo,
    };
  }
}

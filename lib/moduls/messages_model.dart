class MessagesModel {
  MessagesModel({
    this.roomId,
    this.userId,
    this.content,
    this.contentType,
  });

  String? roomId;
  String? userId;
  String? content;
  String? contentType;

  factory MessagesModel.fromJson(Map<String, dynamic> json) => MessagesModel(
        roomId: json["roomId"],
        userId: json["userId"],
        content: json["content"],
        contentType: json["contentType"],
      );

  Map<String, dynamic> toJson() => {
        "roomId": roomId,
        "userId": userId,
        "content": content,
        "contentType": contentType,
      };
}

import '../models/chat_model.dart';

class ChatController {
  List<ChatModel> getChats() {
    return [
      ChatModel(
        name: "Putri",
        role: "UI UX Designer",
        lastMessage: "Sure, I'll send it soon!",
        imagePath: "assets/images/profile_putri.png",
      ),
      ChatModel(
        name: "Andi",
        role: "Web Developer",
        lastMessage: "Project sudah selesai ya",
        imagePath: "assets/images/profile_putri.png",
      ),
    ];
  }
}
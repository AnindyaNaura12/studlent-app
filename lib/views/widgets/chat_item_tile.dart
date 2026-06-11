import 'package:flutter/material.dart';
import '../../models/chat_model.dart';

class ChatItemTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatItemTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    // 🔥 SCALE AMAN (ADA LIMIT)
    double scale(double size) {
      double factor = screenWidth / 375;

      if (factor > 1.2) factor = 1.2;
      if (factor < 0.85) factor = 0.85;

      return size * factor;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 600 : double.infinity,
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isWeb ? 8 : scale(16),
              vertical: scale(6),
            ),
            padding: EdgeInsets.all(scale(12)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(scale(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: scale(8),
                  offset: Offset(0, scale(3)),
                ),
              ],
            ),
            child: Row(
              children: [

                // ================= AVATAR =================
                CircleAvatar(
                  radius: isWeb ? 28 : scale(24),
                  backgroundColor: Colors.white, 
                  backgroundImage: chat.imagePath.startsWith('http') 
                      ? NetworkImage(chat.imagePath) as ImageProvider 
                      : null, 
                  onBackgroundImageError: chat.imagePath.startsWith('http')
                  ? (_, __) {}  
                  : null, 
                  child: !chat.imagePath.startsWith('http') 
                      ? Icon(Icons.person, color: Colors.grey, size: isWeb ? 28 : scale(24)) 
                      : null, 
                ),

                SizedBox(width: scale(12)),

                // ================= TEXT =================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        chat.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isWeb ? 15 : scale(14),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        chat.role,
                        style: TextStyle(
                          fontSize: isWeb ? 12 : scale(11),
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: scale(4)),

                      Text(
                        chat.lastMessage,
                        style: TextStyle(
                          fontSize: isWeb ? 13 : scale(12),
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: scale(8)),

                // ================= RIGHT SIDE =================
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chat.time != null
                          ? "${chat.time!.hour.toString().padLeft(2, '0')}:${chat.time!.minute.toString().padLeft(2, '0')}"
                          : "",
                      style: TextStyle(
                        fontSize: scale(10),
                        color: Colors.grey[500],
                      ),
                    ),

                    SizedBox(height: scale(6)),

                    if (chat.unreadCount > 0)
                      Container(
                        constraints: BoxConstraints(
                          minWidth: scale(20),
                          minHeight: scale(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: scale(6),
                          vertical: scale(3),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(scale(20)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          chat.unreadCount > 99
                              ? '99+'
                              : chat.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: scale(10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
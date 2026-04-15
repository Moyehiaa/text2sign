import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text2sign/const.dart';
import 'package:text2sign/models/message_model.dart';
import 'package:text2sign/services/chat_services.dart';

class ChatTab extends StatefulWidget {
  final String selectedRole;
  final String userName;

  const ChatTab({
    super.key,
    required this.selectedRole,
    required this.userName,
  });

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? chatId;
  String? otherUserId;
  String otherUserName = "User";
  bool isLoading = true;

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;
  bool get isDeaf => widget.selectedRole == "deaf";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!currentUserDoc.exists) {
        throw Exception("Current user data not found");
      }

      final currentUserData = currentUserDoc.data()!;
      final linkedUid = currentUserData['linkedUserUid'];

      if (linkedUid == null || linkedUid.toString().isEmpty) {
        throw Exception("No linked user found");
      }

      final otherUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(linkedUid)
          .get();

      if (!otherUserDoc.exists) {
        throw Exception("Linked user data not found");
      }

      final otherUserData = otherUserDoc.data()!;

      final createdChatId = await _chatService.createOrGetChat(
        otherUserId: linkedUid,
      );

      if (!mounted) return;

      setState(() {
        otherUserId = linkedUid;
        otherUserName = otherUserData['name'] ?? 'User';
        chatId = createdChatId;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Chat error: $e")));
    }
  }

  Future<void> _sendMessage() async {
    if (chatId == null || otherUserId == null) return;
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    await _chatService.sendMessage(
      chatId: chatId!,
      receiverId: otherUserId!,
      text: text,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (chatId == null || otherUserId == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: backgroundColor,
          elevation: 0,
          title: const Text("Chat", style: TextStyle(color: Colors.black)),
        ),
        body: const Center(
          child: Text(
            "No linked user found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isDeaf ? "Caregiver chat" : "Deaf user chat",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(chatId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Start your conversation",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              msg.timestamp == null
                                  ? "Sending..."
                                  : "${msg.timestamp!.hour}:${msg.timestamp!.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: isMe
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

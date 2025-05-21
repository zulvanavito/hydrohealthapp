import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];
  XFile? selectedImage;
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Hydrohealth Assisten",
    profileImage:
        "https://firebasestorage.googleapis.com/v0/b/hydrohealth-project-9cf6c.appspot.com/o/profile_images%2Flogo.jpg?alt=media&token=f55c36e8-83b5-419b-b825-4cf4f4cc69b6",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chat Assistant"),
        backgroundColor: const Color.fromARGB(255, 153, 188, 133),
      ),
      body: Container(
        color: const Color.fromARGB(255, 225, 240, 218),
        child: Column(
          children: [
            if (selectedImage != null) ...[
              Container(
                margin: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.file(
                      File(selectedImage!.path),
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Selected Image',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
                    )
                  ],
                ),
              ),
            ],
            Expanded(child: _buildChatUI()),
          ],
        ),
      ),
    );
  }

  Widget _buildChatUI() {
    return DashChat(
      inputOptions: InputOptions(
        inputDecoration: InputDecoration(
          hintText: "Chat in here",
          filled: true,
          fillColor: const Color.fromARGB(255, 191, 216, 175),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        sendButtonBuilder: (Function() onSend) {
          return IconButton(
            icon: const Icon(Icons.send, color: Colors.black),
            onPressed: onSend,
          );
        },
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(
              Icons.image,
              color: Colors.black,
            ),
          ),
        ],
      ),
      messageOptions: const MessageOptions(
        currentUserContainerColor: Color.fromARGB(255, 212, 231, 197),
        containerColor: Color.fromARGB(255, 191, 216, 175),
        textColor: Colors.black,
        currentUserTextColor: Colors.black,
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    if (selectedImage != null) {
      chatMessage = ChatMessage(
        user: chatMessage.user,
        createdAt: chatMessage.createdAt,
        text: chatMessage.text,
        medias: [
          ChatMedia(
            url: selectedImage!.path,
            fileName: selectedImage!.name,
            type: MediaType.image,
          )
        ],
      );
      selectedImage = null;
    }

    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;

      if (chatMessage.medias != null && chatMessage.medias!.isNotEmpty) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;

        // PERBAIKAN: Cara yang benar untuk extract text dari response
        String response = _extractTextFromResponse(event);

        // Strip out Markdown formatting
        response = response.replaceAll("**", "");

        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  // PERBAIKAN: Helper method untuk extract text dari response
  String _extractTextFromResponse(dynamic event) {
    try {
      // Cek apakah event memiliki content dan parts
      if (event.content?.parts != null && event.content!.parts!.isNotEmpty) {
        // Extract text dari semua parts
        String combinedText = "";
        for (var part in event.content!.parts!) {
          // Cara yang benar untuk mengakses text dari Part
          if (part.text != null) {
            combinedText += part.text!;
          }
        }
        return combinedText;
      }

      // Kalau nggak ada content, return empty string
      return "";
    } catch (e) {
      print("Error extracting text: $e");
      return "";
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {
      setState(() {
        selectedImage = file;
      });
    }
  }
}

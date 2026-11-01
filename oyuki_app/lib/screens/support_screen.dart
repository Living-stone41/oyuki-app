import 'package:flutter/material.dart';
import '../theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
        text: "Hello! I'm Oyuki support chat bot, how can I assist you today?",
        isUser: false,
        time: 'Now'),
  ];
  final _quickReplies = [
    'How to change withdrawal account details',
    'Order issues',
    'Deposit errors',
    'How do I sell on Oyuki',
  ];

  String _timeNow() {
    final t = TimeOfDay.now();
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.period.name}';
  }

  String _botReply(String q) {
    switch (q) {
      case 'How do I sell on Oyuki':
        return 'Scroll down to the end at the profile settings page, click on "I want to sell on Oyuki".\n\nFollow the link and complete registration as a vendor';
      case 'Order issues':
        return 'Sorry about that! Please share your order ID so our team can look into it immediately.';
      case 'Deposit errors':
        return 'If your deposit has not reflected after 24 hours, please share the transaction reference and our team will trace it.';
      case 'How to change withdrawal account details':
        return 'Go to Profile → Wallet → Withdrawal account, tap the edit icon and update your bank details. You will need your 2FA code to confirm.';
      default:
        return 'Thanks for reaching out! A support agent will join this chat shortly.';
    }
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, time: _timeNow()));
    });
    _controller.clear();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(
            text: _botReply(text), isUser: false, time: _timeNow()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.green, size: 20),
        ),
        title: const Text('Support'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.call_outlined, color: AppColors.green),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Column(
                  crossAxisAlignment: m.isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: m.isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!m.isUser)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.lightGrey,
                              child: const Icon(Icons.support_agent, size: 18),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(m.text,
                                style: const TextStyle(color: Colors.white, height: 1.4)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: m.isUser ? 0 : 40, top: 4, bottom: 14),
                      child: Text(m.time,
                          style:
                              const TextStyle(color: AppColors.grey, fontSize: 12)),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _quickReplies
                  .map((q) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(q,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.text)),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.border),
                          onPressed: () => _send(q),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message',
                      hintStyle: TextStyle(color: AppColors.grey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _send,
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.green),
                    onPressed: () {}),
                IconButton(
                    icon: const Icon(Icons.send, color: AppColors.green),
                    onPressed: () => _send(_controller.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

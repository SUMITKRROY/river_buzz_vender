import 'package:flutter/material.dart';
import '../config/theam_data.dart';
import '../data/app_data.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String routeName = 'chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _contactName;
  late bool _isOnline;
  late List<Map<String, dynamic>> _messages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _contactName = args?['name'] as String? ?? 'John Doe';
    _isOnline = args?['isOnline'] as bool? ?? true;
    _messages = List.from(AppData.chatMessagesJohnDoe);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'isMe': true,
        'text': text,
        'time': _formatTime(DateTime.now()),
        'type': 'text',
        'isRead': false,
      });
    });
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day &&
        dt.month == now.month &&
        dt.year == now.year) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min $ampm';
    }
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.lightBlue,
                  child: Icon(
                    Icons.person_rounded,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                if (_isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppTheme.spacingS),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _contactName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingM),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.greyBackground,
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusPill),
                        ),
                        child: Text(
                          'TODAY',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  );
                }
                final msg = _messages[index - 1];
                return _ChatBubble(
                  text: msg['text'] as String?,
                  time: msg['time'] as String? ?? '',
                  isMe: msg['isMe'] as bool? ?? false,
                  type: msg['type'] as String? ?? 'text',
                  isRead: msg['isRead'] as bool? ?? false,
                  showAvatar: !(msg['isMe'] as bool? ?? false),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingS,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: AppTheme.greyBackground,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message $_contactName...',
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: AppTheme.textSecondary,
                            size: 22,
                          ),
                          onPressed: () {},
                        ),
                        filled: true,
                        fillColor: AppTheme.greyBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusLarge),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS + 4,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppTheme.primaryBlue,
                      size: 28,
                    ),
                    onPressed: _sendMessage,
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

class _ChatBubble extends StatelessWidget {
  final String? text;
  final String time;
  final bool isMe;
  final String type;
  final bool isRead;
  final bool showAvatar;

  const _ChatBubble({
    this.text,
    required this.time,
    required this.isMe,
    required this.type,
    required this.isRead,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    if (type == 'image') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (showAvatar) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.lightBlue,
                  child: Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
              ],
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 220,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primaryBlue : AppTheme.greyBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppTheme.borderRadiusMedium),
                    topRight: const Radius.circular(AppTheme.borderRadiusMedium),
                    bottomLeft: Radius.circular(
                        isMe ? AppTheme.borderRadiusMedium : 4),
                    bottomRight: Radius.circular(
                        isMe ? 4 : AppTheme.borderRadiusMedium),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppTheme.borderRadiusMedium),
                    topRight: const Radius.circular(AppTheme.borderRadiusMedium),
                    bottomLeft: Radius.circular(
                        isMe ? AppTheme.borderRadiusMedium : 4),
                    bottomRight: Radius.circular(
                        isMe ? 4 : AppTheme.borderRadiusMedium),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      color: AppTheme.lightBlue,
                      child: Icon(
                        Icons.directions_boat_rounded,
                        size: 48,
                        color: AppTheme.primaryBlue.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: AppTheme.spacingS),
                Icon(
                  isRead ? Icons.done_all_rounded : Icons.done_rounded,
                  size: 16,
                  color: AppTheme.white,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.lightBlue,
                child: Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
            ],
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.primaryBlue : AppTheme.greyBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.borderRadiusMedium),
                  topRight: const Radius.circular(AppTheme.borderRadiusMedium),
                  bottomLeft: Radius.circular(
                      isMe ? AppTheme.borderRadiusMedium : 4),
                  bottomRight: Radius.circular(
                      isMe ? 4 : AppTheme.borderRadiusMedium),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (text != null && text!.isNotEmpty)
                    Text(
                      text!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isMe ? AppTheme.white : AppTheme.textPrimary,
                          ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isMe
                                  ? AppTheme.white.withOpacity(0.9)
                                  : AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 14,
                          color: AppTheme.white.withOpacity(0.9),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../config/theam_data.dart';
import '../constants/app_constants.dart';
import '../data/app_data.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _conversations =
      List.from(AppData.conversations);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(Map<String, dynamic> conversation) {
    Navigator.pushNamed(
      context,
      AppConstants.chatRoute,
      arguments: {
        'id': conversation['id'],
        'name': conversation['name'],
        'isOnline': conversation['isOnline'] ?? false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers or messages',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                filled: true,
                fillColor: AppTheme.greyBackground,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS + 4,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _conversations = List.from(AppData.conversations);
                  } else {
                    _conversations = AppData.conversations
                        .where((c) {
                          final name = (c['name'] as String?)?.toLowerCase() ?? '';
                          final msg = (c['lastMessage'] as String?)?.toLowerCase() ?? '';
                          final v = value.toLowerCase();
                          return name.contains(v) || msg.contains(v);
                        })
                        .toList();
                  }
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              itemCount: _conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final c = _conversations[index];
                return _ConversationTile(
                  name: c['name'] as String,
                  lastMessage: c['lastMessage'] as String? ?? '',
                  time: c['time'] as String? ?? '',
                  isOnline: c['isOnline'] as bool? ?? false,
                  isUnread: c['isUnread'] as bool? ?? false,
                  onTap: () => _openChat(c),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.edit_rounded, color: AppTheme.white),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final bool isUnread;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingM,
            horizontal: AppTheme.spacingXS,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.lightBlue,
                    child: Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lastMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isUnread
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

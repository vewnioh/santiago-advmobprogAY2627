import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:santiago_mobile/widgets/custom_text.dart';

import '../services/chat_service.dart';
import '../services/user_service.dart';

final ChatService chatService = ChatService();

// Enhancement 3: Delivery state of one of my messages
enum MessageStatus { sending, delivered, seen }

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late Future<String> _currentUserIdFuture;

  // Created once the current user's ID is known, so rebuilds do not resubscribe to Firestore
  Stream<QuerySnapshot>? _messagesStream;

  // Enhancement 3: Message IDs already on screen; only IDs not in here get the entrance animation
  final Set<String> _knownMessageIds = {};
  bool _initialMessagesLoaded = false;

  // Prevents firing several "mark as seen" writes at once
  bool _markingSeen = false;

  // Drives the animated send button
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = _getCurrentUserId();
    _msgCtrl.addListener(() {
      final hasText = _msgCtrl.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  Future<String> _getCurrentUserId() async {
    final userData = await userService.value.getUserData();
    return (userData['uid'] ?? '').toString();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String receiverId) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    // Clear right away: the message shows instantly as "sending…" from Firestore's local cache
    _msgCtrl.clear();
    _msgFocus.requestFocus();

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    try {
      await chatService.sendMessage(receiverId, text);
    } catch (e) {
      if (!mounted) return;
      // Give the text back so the user can retry
      if (_msgCtrl.text.isEmpty) _msgCtrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  // Enhancement 3: Marks the other user's messages as seen while this chat is open
  void _markSeenIfNeeded(
    List<QueryDocumentSnapshot> docs,
    String currentUserId,
    String tappedUserId,
  ) {
    if (_markingSeen) return;
    final hasUnseen = docs.any((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['receiverId'] == currentUserId && data['isSeen'] != true;
    });
    if (!hasUnseen) return;

    _markingSeen = true;
    chatService
        .markMessagesAsSeen(currentUserId, tappedUserId)
        .catchError((e) => debugPrint('Failed to mark messages as seen: $e'))
        .whenComplete(() => _markingSeen = false);
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String _formatDay(DateTime time) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${months[time.month - 1]} ${time.day}, ${time.year}';
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _timeOf(Map<String, dynamic> data) {
    final ts = data['timestamp'];
    return ts is Timestamp ? ts.toDate() : DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final tappedUserId = (widget.tappedUser['uid'] ?? '').toString();
    final tappedUserName = (widget.tappedUser['firstName'] ?? '').toString();
    final tappedUserEmail = (widget.tappedUser['email'] ?? '').toString();

    return FutureBuilder<String>(
      future: _currentUserIdFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Error loading user data')),
          );
        }

        final currentUserId = snap.data!;
        _messagesStream ??= chatService.getMessage(currentUserId, tappedUserId);

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            centerTitle: false,
            titleSpacing: 0,
            title: Row(
              children: [
                _Avatar(name: tappedUserName, radius: 18.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: tappedUserName.isNotEmpty ? tappedUserName : 'Unknown',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tappedUserEmail.isNotEmpty)
                        CustomText(
                          text: tappedUserEmail,
                          fontSize: 11.sp,
                          color: Colors.white70,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading messages: ${snapshot.error}'),
                      );
                    }

                    final List<QueryDocumentSnapshot> docs =
                        snapshot.data?.docs ?? [];

                    // Messages from the first load appear without animation; later ones animate in
                    final Set<String> newIds = {};
                    for (final d in docs) {
                      if (!_knownMessageIds.contains(d.id)) newIds.add(d.id);
                    }
                    final Set<String> animateIds =
                        _initialMessagesLoaded ? newIds : {};
                    _knownMessageIds.addAll(newIds);
                    _initialMessagesLoaded = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _markSeenIfNeeded(docs, currentUserId, tappedUserId);
                      }
                    });

                    if (docs.isEmpty) {
                      return _EmptyChat(name: tappedUserName);
                    }

                    // Index of my newest message, which gets the "Sending… / Delivered / Seen" label
                    final int lastMineIndex = docs.indexWhere((d) =>
                        (d.data() as Map<String, dynamic>)['senderId'] ==
                        currentUserId);

                    return ListView.builder(
                      controller: _scrollCtrl,
                      reverse: true,
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final msgText = (data['message'] ?? '').toString();
                        final senderId = (data['senderId'] ?? '').toString();
                        final isMe = senderId == currentUserId;
                        final time = _timeOf(data);

                        // The list is reversed: index - 1 is the newer message, index + 1 the older one
                        final newer = index > 0
                            ? docs[index - 1].data() as Map<String, dynamic>
                            : null;
                        final older = index < docs.length - 1
                            ? docs[index + 1].data() as Map<String, dynamic>
                            : null;

                        // Consecutive messages from the same sender are grouped; only the last one gets a tail
                        final bool isLastInGroup = newer == null ||
                            newer['senderId'] != senderId ||
                            !_isSameDay(_timeOf(newer), time);
                        final bool showDayChip =
                            older == null || !_isSameDay(_timeOf(older), time);

                        final MessageStatus status = doc.metadata.hasPendingWrites
                            ? MessageStatus.sending
                            : (data['isSeen'] == true
                                ? MessageStatus.seen
                                : MessageStatus.delivered);

                        return Column(
                          key: ValueKey(doc.id),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDayChip) _DayChip(label: _formatDay(time)),
                            _AnimatedMessage(
                              animate: animateIds.contains(doc.id),
                              isMe: isMe,
                              child: _MessageBubble(
                                text: msgText.isNotEmpty ? msgText : '[empty]',
                                time: _formatTime(time),
                                isMe: isMe,
                                isLastInGroup: isLastInGroup,
                                status: isMe ? status : null,
                                showStatusLabel: isMe && index == lastMineIndex,
                                senderName: tappedUserName,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // Composer
              _Composer(
                controller: _msgCtrl,
                focusNode: _msgFocus,
                hasText: _hasText,
                onSend: () => _send(tappedUserId),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Initial-letter avatar used in the app bar and beside received messages
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: CustomText(
        text: name.isNotEmpty ? name[0].toUpperCase() : '?',
        fontSize: radius * 0.9,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

// Enhancement 3: Fade + slide entrance for newly arrived messages
class _AnimatedMessage extends StatefulWidget {
  const _AnimatedMessage({
    required this.animate,
    required this.isMe,
    required this.child,
  });

  final bool animate;
  final bool isMe;
  final Widget child;

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: widget.animate ? 0 : 1,
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = curve;
    // My messages slide in from the right, received ones from the left
    _slide = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.25 : -0.25, 0.15),
      end: Offset.zero,
    ).animate(curve);
    if (widget.animate) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// Enhancement 3: Redesigned chat bubble with time, delivery ticks, and sender/receiver styling
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.isLastInGroup,
    required this.status,
    required this.showStatusLabel,
    required this.senderName,
  });

  final String text;
  final String time;
  final bool isMe;
  final bool isLastInGroup;
  final MessageStatus? status;
  final bool showStatusLabel;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color textColor = isMe ? Colors.white : colorScheme.onSurface;
    final Color metaColor =
        isMe ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.55);

    const big = Radius.circular(18);
    const small = Radius.circular(4);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: EdgeInsets.fromLTRB(14.w, 9.h, 12.w, 7.h),
      decoration: BoxDecoration(
        // Sender = green gradient, receiver = neutral surface, so the two sides are easy to tell apart
        gradient: isMe
            ? LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isMe ? null : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: big,
          topRight: big,
          bottomLeft: !isMe && isLastInGroup ? small : big,
          bottomRight: isMe && isLastInGroup ? small : big,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: CustomText(
              text: text,
              fontSize: 15.sp,
              color: textColor,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(text: time, fontSize: 10.sp, color: metaColor),
              if (status != null) ...[
                SizedBox(width: 4.w),
                _StatusIcon(status: status!),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: isLastInGroup ? 8.h : 2.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar only beside the last bubble of a received group; a spacer keeps the rest aligned
              if (!isMe)
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: isLastInGroup
                      ? _Avatar(name: senderName, radius: 13.r)
                      : SizedBox(width: 26.r),
                ),
              bubble,
            ],
          ),
          if (showStatusLabel && status != null)
            Padding(
              padding: EdgeInsets.only(top: 3.h, right: 4.w),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: CustomText(
                  key: ValueKey(status),
                  text: switch (status!) {
                    MessageStatus.sending => 'Sending…',
                    MessageStatus.delivered => 'Delivered',
                    MessageStatus.seen => 'Seen',
                  },
                  fontSize: 10.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Enhancement 3: Clock while sending, single check when delivered, blue double check when seen
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (status) {
      MessageStatus.sending => (Icons.schedule, Colors.white70),
      MessageStatus.delivered => (Icons.done, Colors.white70),
      MessageStatus.seen => (Icons.done_all, const Color(0xFF82B1FF)),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(icon, key: ValueKey(status), size: 14.sp, color: color),
    );
  }
}

// Date separator shown above the first message of each day
class _DayChip extends StatelessWidget {
  const _DayChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomText(
          text: label,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// Shown when the two users have not exchanged any messages yet
class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 20), child: child),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waving_hand_rounded, size: 48.sp, color: colorScheme.primary),
            SizedBox(height: 12.h),
            CustomText(
              text: 'No messages yet',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 4.h),
            CustomText(
              text: 'Say hi to ${name.isNotEmpty ? name : 'them'}!',
              fontSize: 13.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhancement 3: Rounded message composer with an animated send button
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: const TextStyle(fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Send button grows in and turns green once there is text to send
              AnimatedScale(
                scale: hasText ? 1 : 0.85,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasText
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: hasText
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: hasText ? onSend : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../_features.dart';
import 'package:avis_package/src/core/_core.dart';

class ChatPageArgs {
  const ChatPageArgs({
    required this.tripId,
    required this.contactDisplayName,
    this.contactPhone,
    required this.driverDisplayName,
    this.driverId,
    this.customerDisplayName,
  });

  /// Trip id = Firestore chat document id (shared with driver app).
  final String tripId;
  /// Display name of the person the user is chatting with (driver for customer app).
  final String contactDisplayName;
  final String? contactPhone;
  final String driverDisplayName;
  /// Firestore metadata driver id, e.g. driver_19.
  final String? driverId;
  /// Customer name stored in chat metadata for the driver inbox.
  final String? customerDisplayName;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.args});

  final ChatPageArgs? args;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = widget.args ?? _argsFromRoute;
      if (args != null) {
        context.read<ChatProvider>().startChat(
          tripId: args.tripId,
          driverDisplayName: args.driverDisplayName,
          contactDisplayName: args.contactDisplayName,
          contactPhone: args.contactPhone,
          driverId: args.driverId,
          customerDisplayName: args.customerDisplayName,
        );
      }
    });
  }

  ChatPageArgs? get _argsFromRoute {
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is ChatPageArgs) return a;
    return null;
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    context.read<ChatProvider>().disposeChat();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String _) {
    context.read<ChatProvider>().setTyping(true);
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(milliseconds: 800), () {
      context.read<ChatProvider>().setTyping(false);
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final provider = context.read<ChatProvider>();
    final ok = await provider.sendMessage(text);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
      _controller.text = text;
      return;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _launchCall() async {
    final args = widget.args ?? _argsFromRoute;
    final phone = args?.contactPhone?.trim();
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available')),
        );
      }
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args ?? _argsFromRoute;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surface,
              border: Border.all(color: context.colors.border),
            ),
            child: SvgIconWidget(
              name: 'back',
              width: 20.w,
              height: 20.w,
              color: context.colors.tertiaryText,
            ),
          ),
        ),
        body: const Center(child: Text('Missing chat data')),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surface,
              border: Border.all(color: context.colors.border),
            ),
            child: SvgIconWidget(
              name: 'back',
              width: 20.w,
              height: 20.w,
              color: context.colors.tertiaryText,
            ),
          ),
        ),
        title: TextWidget(
          'Chat',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _ContactHeader(
            displayName: args.contactDisplayName,
            onCall: _launchCall,
          ),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final messages = provider.messages;
                final isContactTyping = provider.isContactTyping;
                final loadError =
                    provider.errorMessage != null &&
                    provider.errorMessage!.toLowerCase().contains('load');
                return Column(
                  children: [
                    if (loadError)
                      Material(
                        color: Colors.red.shade100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(
                                    color: context.colors.primaryText,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: provider.clearError,
                                child: Text(
                                  'Dismiss',
                                  style: TextStyle(
                                    color: context.colors.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        reverse: false,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final msg = messages[index];
                              final isMe = !msg.isFromDriver;
                              return _ChatBubble(message: msg, isMe: isMe);
                            }, childCount: messages.length),
                          ),
                          if (isContactTyping)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  bottom: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '...',
                                      style: TextStyle(
                                        color: context.colors.primaryText,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _InputBar(
            controller: _controller,
            onChanged: _onTextChanged,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  const _ContactHeader({required this.displayName, required this.onCall});

  final String displayName;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 38.w,
            width: 38.w,
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: context.colors.inputBorder,
              child: TextWidget(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: AppTextStyles.bodyLargeBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: TextWidget(
              displayName,
              style: AppTextStyles.bodyLargeBold.copyWith(
                color: context.colors.primaryText,
              ),
            ),
          ),
          InkWell(
            onTap: onCall,
            child: SvgIconWidget(
              name: 'phone',
              width: 24.w,
              height: 24.w,
              color: context.colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMe});

  final ChatMessageModel message;
  final bool isMe;

  static String _timeFormat(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox.shrink(),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMe
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : Theme.of(context).brightness == Brightness.light
                    ? context.colors.secondaryContainer
                    : context.colors.tertiaryText,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: TextWidget(
                      message.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWidget(
                        _timeFormat(message.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.colors.secondaryText,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.done_all,
                          size: 14.w,
                          color: context.colors.secondaryText,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        8.w,
        12.h + MediaQuery.paddingOf(context).bottom,
      ),
      color: context.colors.secondaryContainer,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.secondaryText,
                  ),
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => onSend(),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: onSend,
              icon: Icon(
                Icons.send_rounded,
                size: 26.w,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

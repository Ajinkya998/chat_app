// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:chat_app/data/models/chat_message_model.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessageModel> messages;
  final bool isReceiverTyping;
  final bool isReceiverOnline;
  final Timestamp? receiverLastSeen;
  final bool hasMoreMessages;
  final bool isLoadingMoreMessages;
  final bool isUserBlocked;
  final bool amIBlocked;

  const ChatState({
    this.status = ChatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
    this.messages = const [],
    this.isReceiverTyping = false,
    this.isReceiverOnline = false,
    this.receiverLastSeen,
    this.hasMoreMessages = true,
    this.isLoadingMoreMessages = false,
    this.isUserBlocked = false,
    this.amIBlocked = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    String? error,
    String? receiverId,
    String? chatRoomId,
    List<ChatMessageModel>? messages,
    bool? isReceiverTyping,
    bool? isReceiverOnline,
    Timestamp? receiverLastSeen,
    bool? hasMoreMessages,
    bool? isLoadingMoreMessages,
    bool? isUserBlocked,
    bool? amIBlocked,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
      isReceiverTyping: isReceiverTyping ?? this.isReceiverTyping,
      isReceiverOnline: isReceiverOnline ?? this.isReceiverOnline,
      receiverLastSeen: receiverLastSeen ?? this.receiverLastSeen,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      amIBlocked: amIBlocked ?? this.amIBlocked,
    );
  }

  @override
  List<Object?> get props {
    return [
      status,
      error,
      receiverId,
      chatRoomId,
      messages,
      isReceiverTyping,
      isReceiverOnline,
      receiverLastSeen,
      hasMoreMessages,
      isLoadingMoreMessages,
      isUserBlocked,
      amIBlocked,
    ];
  }
}

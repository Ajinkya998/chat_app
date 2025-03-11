// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  StreamSubscription? _messageSubscription;
  bool _isInChat = false;
  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  })  : _chatRepository = chatRepository,
        super(const ChatState());

  void enterChat(String receiverId) async {
    _isInChat = true;
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final chatRoom =
          await _chatRepository.getOrCreateChatRoom(currentUserId, receiverId);
      emit(state.copyWith(
        receiverId: receiverId,
        chatRoomId: chatRoom.id,
        status: ChatStatus.loaded,
      ));
      _subscribeToMessage(chatRoom.id);
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.error, error: "Failed to create a chat room: $e"));
    }
  }

  Future<void> sendMessage(
      {required String content, required String receiverId}) async {
    if (state.chatRoomId == null) return;
    try {
      await _chatRepository.sendMessage(
        chatRoomId: state.chatRoomId!,
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.error, error: "Failed to send message"));
    }
  }

  void _subscribeToMessage(String chatRoomId) {
    _messageSubscription?.cancel();
    _messageSubscription =
        _chatRepository.getMessages(chatRoomId).listen((messages) {
      if (_isInChat) {
        _markMessagesAsRead(chatRoomId);
      }
      emit(state.copyWith(messages: messages, error: null));
    }, onError: (e) {
      emit(state.copyWith(
          error: "Failed to get messages: $e", status: ChatStatus.error));
    });
  }

  Future<void> _markMessagesAsRead(String chatRoomId) async {
    try {
      await _chatRepository.markMessagesAsRead(chatRoomId, currentUserId);
    } catch (e) {
      log("Error marking messages as read: $e");
    }
  }

  Future<void> leaveChat() async {
  _isInChat = false;
  }
}

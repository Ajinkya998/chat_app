// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _blockStatusSubscription;
  StreamSubscription? _amIBlockedSubscription;
  bool _isInChat = false;
  Timer? typingTimer;
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
      _subscribeToOnlineStatus(receiverId);
      _subscribeToTypingStatus(chatRoom.id);
      _subscribeToBlockStatus(receiverId);

      _chatRepository.updateOnlineStatus(currentUserId, true);
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

  void _subscribeToOnlineStatus(String userId) {
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription =
        _chatRepository.getUserOnlineStatus(userId).listen((status) {
      final isOnline = status["isOnline"] as bool;
      final lastSeen = status["lastSeen"] as Timestamp?;

      emit(state.copyWith(
        isReceiverOnline: isOnline,
        receiverLastSeen: lastSeen,
      ));
    }, onError: (error) {
      print("Error getting online status: $error");
    });
  }

  void _subscribeToTypingStatus(String chatRoomId) {
    _typingSubscription?.cancel();
    _typingSubscription =
        _chatRepository.getUserTyingStatus(chatRoomId).listen((status) {
      final isTyping = status["isTyping"] as bool;
      final typingUserId = status["typingUserId"] as String?;

      emit(state.copyWith(
        isReceiverTyping: isTyping && typingUserId != currentUserId,
      ));
    }, onError: (error) {
      print("Error getting typing status: $error");
    });
  }

  void _subscribeToBlockStatus(String otherUserId) {
    _blockStatusSubscription?.cancel();
    _blockStatusSubscription = _chatRepository
        .isUserBlocked(currentUserId, otherUserId)
        .listen((blocked) {
      emit(state.copyWith(
        isUserBlocked: blocked,
      ));

      _amIBlockedSubscription?.cancel();
      _amIBlockedSubscription = _chatRepository
          .isUserBlocked(otherUserId, currentUserId)
          .listen((amIBlocked) {
        emit(state.copyWith(
          amIBlocked: amIBlocked,
        ));
      });
    }, onError: (error) {
      print("Error getting typing status: $error");
    });
  }

  void startTyping() {
    if (state.chatRoomId == null) return;
    typingTimer?.cancel();
    _updateTypingStatus(true);
    typingTimer = Timer(const Duration(seconds: 3), () {
      _updateTypingStatus(false);
    });
  }

  Future<void> _updateTypingStatus(bool isTyping) async {
    if (state.chatRoomId == null) return;

    try {
      await _chatRepository.updateTypingStaus(
          state.chatRoomId!, currentUserId, isTyping);
    } catch (e) {
      print("Error updating typing status: $e");
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _chatRepository.blockUser(currentUserId, userId);
    } catch (e) {
      emit(state.copyWith(error: "Failed to block user: $e"));
    }
  }

  Future<void> unBlockUser(String userId) async {
    try {
      await _chatRepository.unBlockUser(currentUserId, userId);
    } catch (e) {
      emit(state.copyWith(error: "Failed to unblock user: $e"));
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.status != ChatStatus.loaded ||
        state.messages.isEmpty ||
        !state.hasMoreMessages ||
        state.isLoadingMoreMessages) return;

    try {
      emit(state.copyWith(isLoadingMoreMessages: true));
      final lastMessages = state.messages.last;
      final lastDoc = await _chatRepository
          .getChatRoomMessages(state.chatRoomId!)
          .doc(lastMessages.id)
          .get();
      final moreMessages = await _chatRepository
          .loadMoreMessages(state.chatRoomId!, lastDocument: lastDoc);

      if (moreMessages.isEmpty) {
        emit(state.copyWith(
            hasMoreMessages: false, isLoadingMoreMessages: false));
        return;
      }

      emit(
        state.copyWith(
            messages: [...state.messages, ...moreMessages],
            hasMoreMessages: moreMessages.length >= 20,
            isLoadingMoreMessages: false),
      );
    } catch (e) {
      emit(state.copyWith(
          error: "Failed to load more messages: $e",
          isLoadingMoreMessages: false));
    }
  }

  Future<void> leaveChat() async {
    _isInChat = false;
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/logic/cubits/chat/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  })  : _chatRepository = chatRepository,
        super(const ChatState());

  void enterChat(String receiverId) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final chatRoom =
          await _chatRepository.getOrCreateChatRoom(currentUserId, receiverId);
      emit(state.copyWith(
        receiverId: receiverId,
        chatRoomId: chatRoom.id,
        status: ChatStatus.loaded,
      ));
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
}

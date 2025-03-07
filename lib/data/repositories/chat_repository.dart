import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection('chatRooms');

  Future<ChatRoomModel> getOrCreateChatRoom(
      String currentUserId, String otherUserId) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join('_');

    final roomDoc = await _chatRooms.doc(roomId).get();
    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }

    final currentUserData =
        (await firestore.collection('users').doc(currentUserId).get()).data()
            as Map<String, dynamic>;
    final otherUserData =
        (await firestore.collection('users').doc(otherUserId).get()).data()
            as Map<String, dynamic>;

    final participantsName = {
      currentUserId: currentUserData['fullName']?.toString() ?? '',
      otherUserId: otherUserData['fullName']?.toString() ?? ''
    };

    final newRoom = ChatRoomModel(
        id: roomId,
        participants: users,
        participantsName: participantsName,
        lastReadTime: {
          currentUserId: Timestamp.now(),
          otherUserId: Timestamp.now()
        });

    await firestore.collection('chatRooms').doc(roomId).set(newRoom.toMap());
    return newRoom;
  }
}

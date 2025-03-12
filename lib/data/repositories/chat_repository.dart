import 'package:chat_app/data/models/chat_message_model.dart';
import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection('chatRooms');
  CollectionReference getChatRoomMessages(String roomId) {
    return _chatRooms.doc(roomId).collection('messages');
  }

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

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final batch = firestore.batch();
    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = messageRef.doc();

    final message = ChatMessageModel(
      id: messageDoc.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
    );

    batch.set(messageDoc, message.toMap());
    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage": content,
      "lastMessageSenderId": senderId,
      "lastMessageTime": message.timestamp,
    });
    await batch.commit();
  }

  Stream<List<ChatMessageModel>> getMessages(String chatRoomId,
      {DocumentSnapshot? lastDocument}) {
    var query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .limit(20);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<List<ChatMessageModel>> loadMoreMessages(String chatRoomId,
      {required DocumentSnapshot lastDocument}) async {
    final query = getChatRoomMessages(chatRoomId)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ChatMessageModel.fromFirestore(doc))
        .toList();
  }

  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _chatRooms
        .where("participants", arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoomModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<int> getUnreadCount(String chatRoomId, String userId) {
    return getChatRoomMessages(chatRoomId)
        .where("receiverId", isEqualTo: userId)
        .where('status', isEqualTo: MessageStatus.sent.toString())
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    try {
      final batch = firestore.batch();

      final unreadMessages = await getChatRoomMessages(chatRoomId)
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: MessageStatus.sent.toString())
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.read.toString(),
          'readBy': FieldValue.arrayUnion([userId])
        });
      }
      await batch.commit();
    } catch (e) {
      throw "Error marking messages as read: $e";
    }
  }

  Stream<Map<String, dynamic>> getUserOnlineStatus(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return {
        'isOnline': data?['isOnline'] ?? false,
        'lastSeen': data?['lastSeen'] ?? Timestamp.now(),
      };
    });
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await firestore.collection("users").doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  Stream<Map<String, dynamic>> getUserTyingStatus(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return {'isTyping': false, 'typingUserId': null};
      }
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'isTyping': data['isTyping'] ?? false,
        'typingUserId': data['typingUserId'],
      };
    });
  }

  Future<void> updateTypingStaus(
      String chatRoomId, String userId, bool isTyping) async {
    try {
      final doc = await _chatRooms.doc(chatRoomId).get();
      if (!doc.exists) {
        print("Chat Room does not exists");
        return;
      }
      await _chatRooms.doc(chatRoomId).update({
        'isTyping': isTyping,
        'typingUserId': isTyping ? userId : null,
      });
    } catch (e) {
      print("Error updating typing status: $e");
    }
  }
}

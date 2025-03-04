import 'dart:developer';

import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> requestContactPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
    try {
      // Get device contacts with phone number
      final contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);

      // Extract phone numbers and normalize them
      final phoneNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) => {
                'name': contact.displayName,
                'phoneNumber': contact.phones.first.number
                    .replaceAll(RegExp(r'[^\d+]'), ''),
                'photo': contact.photo,
              })
          .toList();


      // Get all the users from firestore
      final userSnapShots = await firestore.collection('users').get();
      final registeredUsers =
          userSnapShots.docs.map((doc) => UserModel.fromFirestore(doc));

      // Match contacts with registered users
      final matchedContacts = phoneNumbers.where((contact) {
        final phoneNumber = contact['phoneNumber'];
        return registeredUsers.any((user) =>
            user.phoneNumber == phoneNumber && user.uid != currentUserId);
      }).map((contact) {
        final registeredUser = registeredUsers
            .firstWhere((user) => user.phoneNumber == contact['phoneNumber']);
        return {
          'id': registeredUser.uid,
          'name': contact['name'],
          'phoneNumber': contact['phoneNumber'],
        };
      }).toList();
      return matchedContacts;
    } catch (e) {
      log("Error getting registered Users");
      return [];
    }
  }
}

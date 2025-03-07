import 'package:chat_app/data/repositories/contact_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth_cubit.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:chat_app/presentation/screens/chat/chat_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder(
                    future: _contactRepository.getRegisteredContacts(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final contacts = snapshot.data!;
                      if (contacts.isEmpty) {
                        return const Center(child: Text("No Contacts Found"));
                      }
                      return ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ListTile(
                            onTap: () {
                              getIt<AppRouter>().push(
                                ChatScreen(
                                    receiverId: contact["id"],
                                    receiverName: contact["name"]),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              child: Text(contact["name"][0].toUpperCase()),
                            ),
                            title: Text(contact["name"]),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
              onPressed: () async {
                await getIt<AuthCubit>().signOutUser();
                getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text("User is Authenticated"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}

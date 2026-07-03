import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '6a323e1a000aaaf57c71';
  static const String databaseId = '6a3aaabc000596e28f2e';
  static const String collectionId = 'todos';

  final Client client;
  late final Account account;
  late final Databases databases;

  AppwriteService() : client = Client() {
    client.setEndpoint(endpoint).setProject(projectId);
    account = Account(client);
    databases = Databases(client);
  }

  // AUTH
  Future<models.User> register(String email, String password, String name) async {
    await account.create(userId: ID.unique(), email: email, password: password, name: name);
    return login(email, password);
  }

  Future<models.User> login(String email, String password) async {
    await account.createEmailPasswordSession(email: email, password: password);
    return account.get();
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  Future<models.User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (_) {
      return null;
    }
  }

  // TODOS
  Future<List<Map<String, dynamic>>> getTodos(String userId) async {
    final result = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [Query.equal('userID', userId)],
    );
    return result.documents.map((d) => {...d.data, '\$id': d.$id}).toList();
  }

  Future<void> createTodo(String title, String userId) async {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: {'title': title, 'isDone': false, 'userID': userId},
    );
  }

  Future<void> toggleTodo(String docId, bool isDone) async {
    await databases.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: docId,
      data: {'isDone': isDone},
    );
  }

  Future<void> deleteTodo(String docId) async {
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: docId,
    );
  }
  // CHAT
  static const String messagesCollectionId = 'messages';

  Future<List<Map<String, dynamic>>> getMessages() async {
    final result = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: messagesCollectionId,
    );
    return result.documents.map((d) => {...d.data, '\$id': d.$id}).toList();
  }

  Future<void> sendMessage(String text, String userId, String username) async {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: messagesCollectionId,
      documentId: ID.unique(),
      data: {'text': text, 'userId': userId, 'username': username},
    );
  }
}
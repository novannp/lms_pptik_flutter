part of 'chat.dart';

class DeleteConversation {
  final ChatRepository chatRepositoryImpl;

  DeleteConversation(this.chatRepositoryImpl);

  Future<Either<Failure, bool>> execute(int conversationIds) async {
    return await chatRepositoryImpl.deleteConversations(conversationIds);
  }
}

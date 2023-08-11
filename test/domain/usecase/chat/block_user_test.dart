import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_pptik/src/domain/usecase/chat/chat.dart';
import 'package:mockito/mockito.dart';

import '../../../helper/test_helper.mocks.dart';

void main() {
  late MockChatRepository chatRepository;
  late BlockUser blockUser;

  setUp(() {
    chatRepository = MockChatRepository();
    blockUser = BlockUser(chatRepository);
  });

  test('should return true when block user succesfully', () async {
    int id = 0;
    //Arrange
    when(chatRepository.blockUser(id))
        .thenAnswer((_) async => const Right(true));
    //Act
    final result = await blockUser.execute(id);
    //Assert
    expect(result, const Right(true));
  });
}

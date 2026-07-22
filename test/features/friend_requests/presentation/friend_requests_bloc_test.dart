import 'package:bloc_test/bloc_test.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/result.dart';
import 'package:chat_app/features/friend_requests/domain/entities/friend_request.dart';
import 'package:chat_app/features/friend_requests/domain/usecases/get_pending_requests_use_case.dart';
import 'package:chat_app/features/friend_requests/domain/usecases/respond_to_request_use_case.dart';
import 'package:chat_app/features/friend_requests/domain/usecases/send_friend_request_use_case.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPendingRequests extends Mock
    implements GetPendingRequestsUseCase {}

class MockRespondToRequest extends Mock implements RespondToRequestUseCase {}

class MockSendFriendRequest extends Mock
    implements SendFriendRequestUseCase {}

void main() {
  final requests = [
    FriendRequest(
      id: 'r1',
      sender: const RequestSender(
        id: 'u2',
        displayName: 'Alice',
        email: 'alice@test.com',
      ),
      createdAt: DateTime(2026, 7, 22),
    ),
    FriendRequest(
      id: 'r2',
      sender: const RequestSender(
        id: 'u3',
        displayName: 'Bob',
        email: 'bob@test.com',
      ),
      createdAt: DateTime(2026, 7, 21),
    ),
  ];

  late MockGetPendingRequests getPending;
  late MockRespondToRequest respond;
  late MockSendFriendRequest send;

  setUp(() {
    getPending = MockGetPendingRequests();
    respond = MockRespondToRequest();
    send = MockSendFriendRequest();
  });

  FriendRequestsBloc buildBloc() =>
      FriendRequestsBloc(getPending, respond, send);

  group('loading', () {
    blocTest<FriendRequestsBloc, FriendRequestsState>(
      'emits loading then success with the pending requests',
      build: buildBloc,
      setUp: () =>
          when(getPending.call).thenAnswer((_) async => Success(requests)),
      act: (bloc) => bloc.add(const FriendRequestsRequested()),
      expect: () => [
        const FriendRequestsState(),
        FriendRequestsState(
          status: FriendRequestsStatus.success,
          requests: requests,
        ),
      ],
    );

    blocTest<FriendRequestsBloc, FriendRequestsState>(
      'emits failure when loading fails',
      build: buildBloc,
      setUp: () => when(getPending.call)
          .thenAnswer((_) async => const Failure(NetworkException())),
      act: (bloc) => bloc.add(const FriendRequestsRequested()),
      expect: () => [
        const FriendRequestsState(),
        const FriendRequestsState(
          status: FriendRequestsStatus.failure,
          failure: NetworkException(),
        ),
      ],
    );
  });

  group('responding', () {
    blocTest<FriendRequestsBloc, FriendRequestsState>(
      'marks the request pending, then removes it on success',
      build: buildBloc,
      seed: () => FriendRequestsState(
        status: FriendRequestsStatus.success,
        requests: requests,
      ),
      setUp: () => when(
        () => respond(
          requestId: 'r1',
          response: RequestResponse.accept,
        ),
      ).thenAnswer((_) async => const Success(null)),
      act: (bloc) => bloc.add(
        const FriendRequestResponded(
          requestId: 'r1',
          response: RequestResponse.accept,
        ),
      ),
      expect: () => [
        FriendRequestsState(
          status: FriendRequestsStatus.success,
          requests: requests,
          pendingIds: const {'r1'},
        ),
        FriendRequestsState(
          status: FriendRequestsStatus.success,
          requests: [requests[1]],
          outcome: const RequestAcceptedOutcome(),
        ),
      ],
    );

    blocTest<FriendRequestsBloc, FriendRequestsState>(
      'keeps the request when responding fails',
      build: buildBloc,
      seed: () => FriendRequestsState(
        status: FriendRequestsStatus.success,
        requests: requests,
      ),
      setUp: () => when(
        () => respond(
          requestId: 'r1',
          response: RequestResponse.decline,
        ),
      ).thenAnswer(
        (_) async => const Failure(NetworkException()),
      ),
      act: (bloc) => bloc.add(
        const FriendRequestResponded(
          requestId: 'r1',
          response: RequestResponse.decline,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.requests, requests);
        expect(bloc.state.pendingIds, isEmpty);
        expect(bloc.state.outcome, isA<RequestFailedOutcome>());
      },
    );
  });

  group('sending', () {
    blocTest<FriendRequestsBloc, FriendRequestsState>(
      'reports a sent outcome on success',
      build: buildBloc,
      setUp: () => when(() => send('new@test.com'))
          .thenAnswer((_) async => const Success(null)),
      act: (bloc) => bloc.add(const FriendRequestSent('new@test.com')),
      verify: (bloc) {
        expect(bloc.state.isSending, isFalse);
        expect(bloc.state.outcome, isA<RequestSentOutcome>());
      },
    );

    blocTest<FriendRequestsBloc, FriendRequestsState>(
      'reports the server message when sending fails',
      build: buildBloc,
      setUp: () => when(() => send('nobody@test.com')).thenAnswer(
        (_) async => const Failure(
          ServerException('No user found with this email', statusCode: 404),
        ),
      ),
      act: (bloc) => bloc.add(const FriendRequestSent('nobody@test.com')),
      verify: (bloc) {
        final outcome = bloc.state.outcome! as RequestFailedOutcome;
        expect(outcome.exception.message, 'No user found with this email');
      },
    );
  });

  test('hasPending and pendingCount reflect the list', () {
    final state = FriendRequestsState(
      status: FriendRequestsStatus.success,
      requests: requests,
    );

    expect(state.hasPending, isTrue);
    expect(state.pendingCount, 2);
    expect(const FriendRequestsState().hasPending, isFalse);
  });
}

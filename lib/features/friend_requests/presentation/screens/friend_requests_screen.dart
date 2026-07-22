import 'package:chat_app/core/constants/app_dimens.dart';
import 'package:chat_app/core/constants/app_durations.dart';
import 'package:chat_app/core/error/app_exception.dart';
import 'package:chat_app/core/error/app_exception_l10n.dart';
import 'package:chat_app/core/l10n/generated/app_localizations.dart';
import 'package:chat_app/core/widgets/app_state_view.dart';
import 'package:chat_app/features/friend_requests/presentation/bloc/friend_requests_bloc.dart';
import 'package:chat_app/features/friend_requests/presentation/widgets/add_friend_dialog.dart';
import 'package:chat_app/features/friend_requests/presentation/widgets/friend_request_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FriendRequestsBloc>().add(const FriendRequestsRequested());
  }

  Future<void> _openAddFriendDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) => const AddFriendDialog(),
    );
    if (email == null || !mounted) return;
    context.read<FriendRequestsBloc>().add(FriendRequestSent(email));
  }

  void _showOutcome(BuildContext context, RequestOutcome outcome) {
    final l10n = AppLocalizations.of(context);
    final message = switch (outcome) {
      RequestSentOutcome() => l10n.requestSent,
      RequestAcceptedOutcome() => l10n.requestAccepted,
      RequestDeclinedOutcome() => l10n.requestDeclined,
      RequestFailedOutcome(:final exception) =>
        exception.localizedMessage(l10n),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    context.read<FriendRequestsBloc>().add(
          const FriendRequestsOutcomeCleared(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.friendRequests)),
      floatingActionButton:
          BlocSelector<FriendRequestsBloc, FriendRequestsState, bool>(
        selector: (state) => state.isSending,
        builder: (context, isSending) => FloatingActionButton.extended(
          onPressed: isSending ? null : _openAddFriendDialog,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(l10n.addFriend),
        ),
      ),
      body: BlocConsumer<FriendRequestsBloc, FriendRequestsState>(
        listenWhen: (previous, current) =>
            current.outcome != null && previous.outcome != current.outcome,
        listener: (context, state) => _showOutcome(context, state.outcome!),
        builder: (context, state) => switch (state.status) {
          FriendRequestsStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          FriendRequestsStatus.failure => _RequestsFailure(
              failure: state.failure!,
            ),
          FriendRequestsStatus.success when state.isEmpty =>
            const _NoRequests(),
          FriendRequestsStatus.success => _RequestList(state: state),
        },
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({required this.state});

  final FriendRequestsState state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<FriendRequestsBloc>().add(
            const FriendRequestsRefreshed(),
          ),
      child: ListView.separated(
        padding: const EdgeInsets.only(
          top: AppDimens.spaceS,
          bottom: AppDimens.navBarClearance,
        ),
        itemCount: state.requests.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          indent: AppDimens.spaceXxl + AppDimens.spaceM,
        ),
        itemBuilder: (context, index) {
          final request = state.requests[index];
          // Keyed by id so a removed row does not hand its animation
          // state to the row that shifts up into its place.
          return AnimatedSize(
            key: ValueKey(request.id),
            duration: AppDurations.fast,
            child: FriendRequestTile(
              request: request,
              isProcessing: state.awaitingResponseIds.contains(request.id),
              onRespond: (response) =>
                  context.read<FriendRequestsBloc>().add(
                        FriendRequestResponded(
                          requestId: request.id,
                          response: response,
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}

class _NoRequests extends StatelessWidget {
  const _NoRequests();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppStateView(
      icon: Icons.person_add_alt_1_outlined,
      title: l10n.noRequestsTitle,
      message: l10n.noRequestsMessage,
    );
  }
}

class _RequestsFailure extends StatelessWidget {
  const _RequestsFailure({required this.failure});

  final AppException failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isOffline = failure is NetworkException;

    return AppStateView(
      icon: isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: isOffline ? l10n.errorNetworkTitle : l10n.errorGenericTitle,
      message: failure.localizedMessage(l10n),
      onRetry: () => context.read<FriendRequestsBloc>().add(
            const FriendRequestsRequested(),
          ),
    );
  }
}

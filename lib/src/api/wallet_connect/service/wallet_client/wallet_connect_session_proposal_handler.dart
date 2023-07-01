import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:walletconnect_flutter_v2/apis/models/basic_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_events.dart';
import 'package:walletconnect_flutter_v2/apis/utils/errors.dart';

/// Handles session proposals received from apps that have been paired with wallet client.
abstract class WalletConnectSessionProposalHandler {
  /// Displays session proposal information to user and allows them to reject or approve the session.
  Future<bool> handleProposal({
    required SessionProposalEvent args,
  });
}

extension ProcessProposal on WalletConnectSessionProposalHandler {
  /// Validates session proposal before handling proposal.
  Future<void> processProposal({
    required SessionProposalEvent args,
    required Future<void> Function(WalletConnectError reason) reject,
    required Future<void> Function() approve,
  }) async {
    final requiredNamespaces = args.params.requiredNamespaces;

    if (requiredNamespaces['chia'] == null) {
      await reject(Errors.getSdkError(Errors.NON_CONFORMING_NAMESPACES));
      return;
    }

    final unsupportedChains = <String>[];
    requiredNamespaces.forEach(
      (key, value) => unsupportedChains.addAll(
        value.chains!.where((chain) => chain != walletConnectChainId),
      ),
    );

    if (unsupportedChains.isNotEmpty) {
      await reject(Errors.getSdkError(Errors.UNSUPPORTED_CHAINS));
      return;
    }

    final unsupportedCommands = <String>[];
    requiredNamespaces.forEach(
      (key, value) => unsupportedCommands.addAll(
        value.methods
            .where((method) => !WalletConnectCommandType.values.commandNames.contains(method)),
      ),
    );

    if (unsupportedCommands.isNotEmpty) {
      await reject(Errors.getSdkError(Errors.UNSUPPORTED_METHODS));
      return;
    }

    final approved = await handleProposal(args: args);

    if (approved) {
      await approve();
    } else {
      await reject(Errors.getSdkError(Errors.USER_REJECTED));
    }
  }
}

class UnsupportedCommandsException implements Exception {
  const UnsupportedCommandsException(this.unsupportedCommands);

  final List<String> unsupportedCommands;

  @override
  String toString() => 'App requesting unsupported commands: $unsupportedCommands';
}

import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:test/test.dart';

void main() async {
  ChiaNetworkContextWrapper().registerNetworkContext(Network.mainnet);

  if (!(await SimulatorUtils.checkIfSimulatorIsRunning())) {
    print(SimulatorUtils.simulatorNotRunningWarning);
    return;
  }

  final fullNodeSimulator = SimulatorFullNodeInterface.withDefaultUrl();

  final nathan = ChiaEnthusiast(fullNodeSimulator);

  final grant = ChiaEnthusiast(fullNodeSimulator);

  await nathan.farmCoins();

  // set up context, services
  ChiaNetworkContextWrapper().registerNetworkContext(Network.mainnet);
  final catWalletService = EverythingWithSignatureTailService();

  final tailPrivateKey =
      nathan.keychain.unhardenedWalletVectors.first.childPrivateKey;

  test('should issue cat multiple times', () async {
    final standardCoin =
        nathan.standardCoins.firstWhere((coin) => coin.amount >= 10000);
    final issuanceResult = catWalletService.makeIssuanceSpendBundle(
      standardCoins: [standardCoin],
      tailPrivateKey: tailPrivateKey,
      destinationPuzzlehash: nathan.firstPuzzlehash,
      changePuzzlehash: nathan.firstPuzzlehash,
      amount: 10000,
      keychain: nathan.keychain,
    );

    await fullNodeSimulator.pushTransaction(issuanceResult.spendBundle);
    await fullNodeSimulator.moveToNextBlock();

    await nathan.refreshCoins();

    final meltBundle = catWalletService.makeMeltSpendBundle(
      catCoinToMelt: nathan.catCoins.first,
      puzzlehashToClaimXchTo: grant.firstPuzzlehash,
      standardCoinsForXchClaimingSpendBundle: nathan.standardCoins,
      tailPrivateKey: tailPrivateKey,
      changePuzzlehash: nathan.firstPuzzlehash,
      keychain: nathan.keychain,
    );

    await fullNodeSimulator.pushTransaction(meltBundle);
    await fullNodeSimulator.moveToNextBlock();

    await grant.refreshCoins();
    expect(grant.standardCoins.totalValue, 10000);
  });
}

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:bip39/bip39.dart';
import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:chia_crypto_utils/src/command/plot_nft/create_new_wallet_with_plotnft.dart';
import 'package:chia_crypto_utils/src/command/plot_nft/get_farming_status.dart';

late final ChiaFullNodeInterface fullNode;

void main(List<String> args) {
  final runner = CommandRunner<Future<void>>(
    'ccu',
    'Chia Crypto Utils Command Line Tools',
  )
    ..argParser.addOption(
      'log-level',
      defaultsTo: 'none',
      allowed: ['none', 'low', 'high'],
    )
    ..argParser.addOption('network', defaultsTo: 'mainnet')
    ..argParser.addOption('full-node-url')
    ..addCommand(CreateWalletWithPlotNFTCommand())
    ..addCommand(GetFarmingStatusCommand());

  final results = runner.argParser.parse(args);

  parseHelp(results, runner);

  if (results['full-node-url'] == null) {
    print('Option full-node-url is mandatory.');
    printUsage(runner);
    exit(126);
  }

  // Configure environment based on user selections
  LoggingContext()
      .setLogLevel(stringToLogLevel(results['log-level'] as String));
  ChiaNetworkContextWrapper()
      .registerNetworkContext(stringToNetwork(results['network'] as String));
  // construct the Chia full node interface
  fullNode = ChiaFullNodeInterface.fromURL(
    results['full-node-url'] as String,
  );

  runner.run(args);
}

class CreateWalletWithPlotNFTCommand extends Command<Future<void>> {
  CreateWalletWithPlotNFTCommand() {
    argParser
      ..addOption('pool-url', defaultsTo: 'https://xch-us-west.flexpool.io')
      ..addOption(
        'certificate-bytes-path',
        defaultsTo: 'mozilla-ca/cacert.pem',
      );
  }

  @override
  String get description => 'Creates a wallet with a new PlotNFT';

  @override
  String get name => 'Create-WalletWithPlotNFT';

  @override
  Future<void> run() async {
    final poolService = _getPoolService(
      argResults!['pool-url'] as String,
      argResults!['certificate-bytes-path'] as String,
    );
    final mnemonicPhrase = generateMnemonic(strength: 256);
    final mnemonic = mnemonicPhrase.split(' ');
    print('Mnemonic Phrase: $mnemonic');

    final keychainSecret = KeychainCoreSecret.fromMnemonic(mnemonic);
    final keychain = WalletKeychain.fromCoreSecret(
      keychainSecret,
    );

    final coinAddress = Address.fromPuzzlehash(
      keychain.puzzlehashes[0],
      ChiaNetworkContextWrapper().blockchainNetwork.addressPrefix,
    );

    print(
      'Please send at least 1 mojo and enough extra XCH to cover the fee to create the PlotNFT to: $coinAddress\n',
    );
    print('Press any key when coin has been sent');
    stdin.readLineSync();

    var coins = <Coin>[];
    while (coins.isEmpty) {
      print('waiting for coin...');
      await Future<void>.delayed(const Duration(seconds: 3));
      coins = await fullNode.getCoinsByPuzzleHashes(
        keychain.puzzlehashes,
        includeSpentCoins: true,
      );

      if (coins.isNotEmpty) {
        print(coins);
      }
    }

    try {
      await createNewWalletWithPlotNFT(
        keychainSecret,
        keychain,
        poolService,
        fullNode,
      );
    } catch (e) {
      LoggingContext().log(e.toString());
    }
  }
}

class GetFarmingStatusCommand extends Command<Future<void>> {
  GetFarmingStatusCommand() {
    argParser.addOption(
      'certificate-bytes-path',
      defaultsTo: 'mozilla-ca/cacert.pem',
    );
  }

  @override
  String get description => 'Gets the farming status of a mnemonic';

  @override
  String get name => 'Get-FarmingStatus';

  @override
  Future<void> run() async {
    final mnemonicPhrase = stdin.readLineSync();
    if (mnemonicPhrase == null) {
      throw ArgumentError('Must supply a mnemonic phrase to check');
    }

    final mnemonic = mnemonicPhrase.split(' ');

    if (mnemonic.length != 12 && mnemonic.length != 24) {
      throw ArgumentError(
        'Invalid mnemonic phrase. Must contain either 12 or 24 seed words',
      );
    }

    final keychainSecret = KeychainCoreSecret.fromMnemonic(mnemonic);
    final keychain = WalletKeychain.fromCoreSecret(
      keychainSecret,
    );

    final plotNfts = await fullNode.scroungeForPlotNfts(keychain.puzzlehashes);
    for (final plotNft in plotNfts) {
      final poolService = _getPoolService(
        plotNft.poolState.poolUrl!,
        argResults!['certificate-bytes-path'] as String,
      );
      await getFarmingStatus(
        plotNft,
        keychainSecret,
        keychain,
        poolService,
        fullNode,
      );
    }
  }
}

void printUsage(CommandRunner runner) {
  print(runner.argParser.usage);
  print('\nAvailable commands:');
  for (final command in runner.commands.keys) {
    print('    $command');
  }
}

void parseHelp(ArgResults results, CommandRunner runner) {
  if (results.command == null ||
      results.wasParsed('help') ||
      results.command?.name == 'help') {
    if (results.arguments.isEmpty || results.command == null) {
      print('No command was provided.');
    }
    printUsage(runner);
    exit(0);
  }
}

PoolService _getPoolService(String poolUrl, String certificateBytesPath) {
  // clone this for certificate chain: https://github.com/Chia-Network/mozilla-ca.git
  final poolInterface = PoolInterface.fromURLAndCertificate(
    poolUrl,
    certificateBytesPath,
  );

  return PoolService(poolInterface, fullNode);
}

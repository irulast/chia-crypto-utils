// ignore_for_file: lines_longer_than_80_chars
@Timeout(Duration(minutes: 1))

import 'dart:async';

import 'package:bip39/bip39.dart';
import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:chia_crypto_utils/src/exchange/btc/service/btc_to_xch.dart';
import 'package:chia_crypto_utils/src/exchange/btc/service/exchange.dart';
import 'package:chia_crypto_utils/src/exchange/btc/service/xch_to_btc.dart';
import 'package:chia_crypto_utils/src/exchange/btc/utils/decode_lightning_payment_request.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

Future<void> main() async {
  if (!(await SimulatorUtils.checkIfSimulatorIsRunning())) {
    print(SimulatorUtils.simulatorNotRunningWarning);
    return;
  }

  final simulatorHttpRpc = SimulatorHttpRpc(
    SimulatorUtils.simulatorUrl,
    certBytes: SimulatorUtils.certBytes,
    keyBytes: SimulatorUtils.keyBytes,
  );

  final fullNodeSimulator = SimulatorFullNodeInterface(simulatorHttpRpc);

  ChiaNetworkContextWrapper().registerNetworkContext(Network.mainnet);
  final walletService = StandardWalletService();
  final exchangeService = BtcExchangeService();

  test(
      'should transfer XCH to chiaswap address and fail to clawback funds to XCH holder before delay has passed',
      () async {
    final xchToBtcService = XchToBtcService();

    final xchHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    await xchHolder.farmCoins();
    await xchHolder.refreshCoins();

    // generate disposable mnemonic and keychain for user
    final disposableMnemonic = generateMnemonic(strength: 256);
    final disposableKeychainSecret = KeychainCoreSecret.fromMnemonic(disposableMnemonic.split(' '));

    final walletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(disposableKeychainSecret.masterPrivateKey, i);
      walletsSetList.add(set1);
    }

    final disposableKeychain = WalletKeychain.fromWalletSets(walletsSetList);

    final disposableKeychainPuzzlehash = disposableKeychain.unhardenedMap.values.first.puzzlehash;

    // user transfers funds to the disposable keychain
    final coins = xchHolder.standardCoins;

    final coinsToSend = coins.sublist(0, 2);
    coins.removeWhere(coinsToSend.contains);

    final coinsValue = coinsToSend.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );
    final amountToSend = (coinsValue * 0.8).round();
    final fee = (coinsValue * 0.1).round();

    final spendBundle = walletService.createSpendBundle(
      payments: [Payment(amountToSend, disposableKeychainPuzzlehash)],
      coinsInput: coinsToSend,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: xchHolder.keychain,
      fee: fee,
    );

    await fullNodeSimulator.pushTransaction(spendBundle);
    await fullNodeSimulator.moveToNextBlock();

    // user inputs signed public key of counter party, which is parsed and validated to ensure that
    // it was generated by our exchange service
    const btcHolderSignedPublicKey =
        'ac72743c39137845af0991c71796206c7784b49b76fa30f216ccdeba84e23b28b81d5af48a6cc754d6438057c084f206_b60876a2f323721d8404935991b2c2e392af7e07d93aeb68317646a4c72b7392c00c88331e1ca90330cc9511cd6f2a510b55ee0918ed4d1d58dbf06c805044b9dc906a58ed5252e9dd95d22ccdc9f3016e1848d95f998a2bfbe6f74f5040f688';
    final btcHolderPublicKey = exchangeService.parseSignedPublicKey(btcHolderSignedPublicKey);

    // user inputs lightning payment request, which is decoded to get the payment hash
    const paymentRequest =
        'lnbc1u1p3huyzkpp5vw6fkrw9lr3pvved40zpp4jway4g4ee6uzsaj208dxqxgm2rtkvqdqqcqzzgxqyz5vqrzjqwnvuc0u4txn35cafc7w94gxvq5p3cu9dd95f7hlrh0fvs46wpvhdrxkxglt5qydruqqqqryqqqqthqqpyrzjqw8c7yfutqqy3kz8662fxutjvef7q2ujsxtt45csu0k688lkzu3ldrxkxglt5qydruqqqqryqqqqthqqpysp5jzgpj4990chtj9f9g2f6mhvgtzajzckx774yuh0klnr3hmvrqtjq9qypqsqkrvl3sqd4q4dm9axttfa6frg7gffguq3rzuvvm2fpuqsgg90l4nz8zgc3wx7gggm04xtwq59vftm25emwp9mtvmvjg756dyzn2dm98qpakw4u8';
    final decodedPaymentRequest = decodeLightningPaymentRequest(paymentRequest);
    final sweepPaymentHash = decodedPaymentRequest.tags.paymentHash;

    // generate address for XCH holder to send funds to
    final chiaswapPuzzleAddress = xchToBtcService.generateChiaswapPuzzleAddress(
      requestorKeychain: disposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: btcHolderPublicKey,
    );

    final chiaswapPuzzlehash = chiaswapPuzzleAddress.toPuzzlehash();

    // XCH holder transfers funds from disposable keychain to chiaswap address
    final coinsForChiaswap =
        await fullNodeSimulator.getCoinsByPuzzleHashes([disposableKeychainPuzzlehash]);

    final amountForChiaswap = coinsForChiaswap.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );

    final chiaswapTransferSpendbundle = walletService.createSpendBundle(
      payments: [Payment(amountForChiaswap, chiaswapPuzzlehash)],
      coinsInput: coinsForChiaswap,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: disposableKeychain,
    );
    await fullNodeSimulator.pushTransaction(chiaswapTransferSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final chiaswapAddressBalance = await fullNodeSimulator.getBalance([chiaswapPuzzlehash]);

    expect(chiaswapAddressBalance, amountForChiaswap);

    final chiaswapAddressCoins =
        await fullNodeSimulator.getCoinsByPuzzleHashes([chiaswapPuzzleAddress.toPuzzlehash()]);

    // user specifies where they want to receive coins in clawback case
    final clawbackPuzzlehash = xchHolder.firstPuzzlehash;

    // the clawback spend bundle will fail if pushed before the clawback delay period passes
    // the default delay is 24 hours
    final clawbackSpendbundle = xchToBtcService.createClawbackSpendBundle(
      payments: [Payment(chiaswapAddressBalance, clawbackPuzzlehash)],
      coinsInput: chiaswapAddressCoins,
      requestorKeychain: disposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: btcHolderPublicKey,
    );

    expect(
      () async {
        await fullNodeSimulator.pushTransaction(clawbackSpendbundle);
      },
      throwsException,
    );
  });

  test(
      'should transfer XCH to chiaswap address and clawback funds to XCH holder after delay has passed',
      () async {
    final xchToBtcService = XchToBtcService();

    final xchHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    await xchHolder.farmCoins();
    await xchHolder.refreshCoins();

    // generate disposable mnemonic and keychain for user
    final disposableMnemonic = generateMnemonic(strength: 256);
    final disposableKeychainSecret = KeychainCoreSecret.fromMnemonic(disposableMnemonic.split(' '));

    final walletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(disposableKeychainSecret.masterPrivateKey, i);
      walletsSetList.add(set1);
    }

    final disposableKeychain = WalletKeychain.fromWalletSets(walletsSetList);

    final disposableKeychainPuzzlehash = disposableKeychain.unhardenedMap.values.first.puzzlehash;

    // user transfers funds to the disposable keychain
    final coins = xchHolder.standardCoins;

    final coinsToSend = coins.sublist(0, 2);
    coins.removeWhere(coinsToSend.contains);

    final coinsValue = coinsToSend.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );
    final amountToSend = (coinsValue * 0.8).round();
    final fee = (coinsValue * 0.1).round();

    final spendBundle = walletService.createSpendBundle(
      payments: [Payment(amountToSend, disposableKeychainPuzzlehash)],
      coinsInput: coinsToSend,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: xchHolder.keychain,
      fee: fee,
    );

    await fullNodeSimulator.pushTransaction(spendBundle);
    await fullNodeSimulator.moveToNextBlock();

    // user inputs signed public key of counter party, which is parsed and validated to ensure that
    // it was generated by our exchange service
    const btcHolderSignedPublicKey =
        'ac72743c39137845af0991c71796206c7784b49b76fa30f216ccdeba84e23b28b81d5af48a6cc754d6438057c084f206_b60876a2f323721d8404935991b2c2e392af7e07d93aeb68317646a4c72b7392c00c88331e1ca90330cc9511cd6f2a510b55ee0918ed4d1d58dbf06c805044b9dc906a58ed5252e9dd95d22ccdc9f3016e1848d95f998a2bfbe6f74f5040f688';
    final btcHolderPublicKey = exchangeService.parseSignedPublicKey(btcHolderSignedPublicKey);

    // user inputs lightning payment request, which is decoded to get the payment hash
    const paymentRequest =
        'lnbc1u1p3huyzkpp5vw6fkrw9lr3pvved40zpp4jway4g4ee6uzsaj208dxqxgm2rtkvqdqqcqzzgxqyz5vqrzjqwnvuc0u4txn35cafc7w94gxvq5p3cu9dd95f7hlrh0fvs46wpvhdrxkxglt5qydruqqqqryqqqqthqqpyrzjqw8c7yfutqqy3kz8662fxutjvef7q2ujsxtt45csu0k688lkzu3ldrxkxglt5qydruqqqqryqqqqthqqpysp5jzgpj4990chtj9f9g2f6mhvgtzajzckx774yuh0klnr3hmvrqtjq9qypqsqkrvl3sqd4q4dm9axttfa6frg7gffguq3rzuvvm2fpuqsgg90l4nz8zgc3wx7gggm04xtwq59vftm25emwp9mtvmvjg756dyzn2dm98qpakw4u8';
    final decodedPaymentRequest = decodeLightningPaymentRequest(paymentRequest);
    final sweepPaymentHash = decodedPaymentRequest.tags.paymentHash;

    // shorten delay for testing purposes
    const clawbackDelaySeconds = 5;

    // generate address for XCH holder to send funds to
    final chiaswapPuzzleAddress = xchToBtcService.generateChiaswapPuzzleAddress(
      requestorKeychain: disposableKeychain,
      clawbackDelaySeconds: clawbackDelaySeconds,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: btcHolderPublicKey,
    );

    final chiaswapPuzzlehash = chiaswapPuzzleAddress.toPuzzlehash();

    // XCH holder transfers funds from disposable keychain to chiaswap address
    final coinsForChiaswap =
        await fullNodeSimulator.getCoinsByPuzzleHashes([disposableKeychainPuzzlehash]);

    final amountForChiaswap = coinsForChiaswap.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );

    final chiaswapTransferSpendbundle = walletService.createSpendBundle(
      payments: [Payment(amountForChiaswap, chiaswapPuzzlehash)],
      coinsInput: coinsForChiaswap,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: disposableKeychain,
    );
    await fullNodeSimulator.pushTransaction(chiaswapTransferSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final chiaswapAddressBalance = await fullNodeSimulator.getBalance([chiaswapPuzzlehash]);

    final chiaswapAddressCoins =
        await fullNodeSimulator.getCoinsByPuzzleHashes([chiaswapPuzzleAddress.toPuzzlehash()]);

    // user specifies where they want to receive coins in clawback case
    final clawbackPuzzlehash = xchHolder.firstPuzzlehash;

    final startingClawbackAddressBalance = await fullNodeSimulator.getBalance([clawbackPuzzlehash]);

    // the clawback spend bundle can be pushed after the clawback delay has passed in order to reclaim funds
    // in the event that the other party doesn't pay the lightning invoice within that time
    final clawbackSpendbundle = xchToBtcService.createClawbackSpendBundle(
      payments: [Payment(chiaswapAddressBalance, clawbackPuzzlehash)],
      coinsInput: chiaswapAddressCoins,
      clawbackDelaySeconds: clawbackDelaySeconds,
      requestorKeychain: disposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: btcHolderPublicKey,
    );

    // the earliest you can spend a time-locked coin is 2 blocks later, since the time is checked
    // against the timestamp of the previous block
    for (var i = 0; i < 2; i++) {
      await fullNodeSimulator.moveToNextBlock();
    }

    // wait until clawback delay period has passed
    await Future<void>.delayed(const Duration(seconds: 10), () async {
      await fullNodeSimulator.pushTransaction(clawbackSpendbundle);
      await fullNodeSimulator.moveToNextBlock();
      final endingClawbackAddressBalance = await fullNodeSimulator.getBalance([clawbackPuzzlehash]);

      expect(
        endingClawbackAddressBalance,
        equals(startingClawbackAddressBalance + chiaswapAddressBalance),
      );
    });
  });

  test('should transfer XCH to chiaswap address and sweep funds to BTC holder using preimage',
      () async {
    final btcToXchService = BtcToXchService();
    final xchHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    final btcHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    await xchHolder.farmCoins();
    await xchHolder.refreshCoins();

    // generate disposable mnemonic and keychain for user
    final btcDisposableMnemonic = generateMnemonic(strength: 256);
    final btcDisposableKeychainSecret =
        KeychainCoreSecret.fromMnemonic(btcDisposableMnemonic.split(' '));

    final btcWalletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(btcDisposableKeychainSecret.masterPrivateKey, i);
      btcWalletsSetList.add(set1);
    }

    final btcDisposableKeychain = WalletKeychain.fromWalletSets(btcWalletsSetList);

    // xchHolder also has disposable mnemonic and keychain generated for them when they use the
    // exchange service
    final xchDisposableMnemonic = generateMnemonic(strength: 256);
    final xchDisposableKeychainSecret =
        KeychainCoreSecret.fromMnemonic(xchDisposableMnemonic.split(' '));

    final xchWalletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(xchDisposableKeychainSecret.masterPrivateKey, i);
      xchWalletsSetList.add(set1);
    }

    final xchDisposableKeychain = WalletKeychain.fromWalletSets(btcWalletsSetList);

    final xchDisposableKeychainPuzzlehash =
        xchDisposableKeychain.unhardenedMap.values.first.puzzlehash;

    // xchHolder transfers funds to the disposable keychain
    final coins = xchHolder.standardCoins;

    final coinsToSend = coins.sublist(0, 2);
    coins.removeWhere(coinsToSend.contains);

    final coinsValue = coinsToSend.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );
    final amountToSend = (coinsValue * 0.8).round();
    final fee = (coinsValue * 0.1).round();

    final spendBundle = walletService.createSpendBundle(
      payments: [Payment(amountToSend, xchDisposableKeychainPuzzlehash)],
      coinsInput: coinsToSend,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: xchHolder.keychain,
      fee: fee,
    );

    await fullNodeSimulator.pushTransaction(spendBundle);
    await fullNodeSimulator.moveToNextBlock();

    // user inputs signed public key of counter party, which is parsed and validated to ensure that
    // it was generated by our exchange service
    const xchHolderSignedPublicKey =
        'ad6abe3d432ccce5b40995611c4db6d71e2678f142b8635940c32c4b1c35dde7b01ab42581075eaee173aba747373f71_97c0d2c1acea7708df1eb4a75f625ca1fe95a9aa141a86c2e18bdfd1e8716cba2888f6230ea122ce9478a78f8257beaf0dfb81714f4de6337fa671cc29bb2d4e18e9aae31829016fd94f14e99f86a9ad990f2740d02583c6a85dc4b6b0233aaa';
    final xchHolderPublicKey = exchangeService.parseSignedPublicKey(xchHolderSignedPublicKey);

    // user inputs lightning payment request, which is decoded to get the payment hash
    const paymentRequest =
        'lnbc1u1p3huyzkpp5vw6fkrw9lr3pvved40zpp4jway4g4ee6uzsaj208dxqxgm2rtkvqdqqcqzzgxqyz5vqrzjqwnvuc0u4txn35cafc7w94gxvq5p3cu9dd95f7hlrh0fvs46wpvhdrxkxglt5qydruqqqqryqqqqthqqpyrzjqw8c7yfutqqy3kz8662fxutjvef7q2ujsxtt45csu0k688lkzu3ldrxkxglt5qydruqqqqryqqqqthqqpysp5jzgpj4990chtj9f9g2f6mhvgtzajzckx774yuh0klnr3hmvrqtjq9qypqsqkrvl3sqd4q4dm9axttfa6frg7gffguq3rzuvvm2fpuqsgg90l4nz8zgc3wx7gggm04xtwq59vftm25emwp9mtvmvjg756dyzn2dm98qpakw4u8';
    final decodedPaymentRequest = decodeLightningPaymentRequest(paymentRequest);
    final sweepPaymentHash = decodedPaymentRequest.tags.paymentHash;

    // generate address for XCH holder to send funds to
    final chiaswapPuzzleAddress = btcToXchService.generateChiaswapPuzzleAddress(
      requestorKeychain: btcDisposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: xchHolderPublicKey,
    );

    final chiaswapPuzzlehash = chiaswapPuzzleAddress.toPuzzlehash();

    // XCH holder transfers funds from disposable keychain to chiaswap address
    final coinsForChiaswap =
        await fullNodeSimulator.getCoinsByPuzzleHashes([xchDisposableKeychainPuzzlehash]);

    final amountForChiaswap = coinsForChiaswap.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );

    final chiaswapTransferSpendbundle = walletService.createSpendBundle(
      payments: [Payment(amountForChiaswap, chiaswapPuzzlehash)],
      coinsInput: coinsForChiaswap,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: btcDisposableKeychain,
    );
    await fullNodeSimulator.pushTransaction(chiaswapTransferSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final chiaswapAddressBalance = await fullNodeSimulator.getBalance([chiaswapPuzzlehash]);

    final chiaswapAddressCoins =
        await fullNodeSimulator.getCoinsByPuzzleHashes([chiaswapPuzzleAddress.toPuzzlehash()]);

    // user specifies where they want to receive funds
    final sweepPuzzlehash = btcHolder.firstPuzzlehash;
    final startingSweepAddressBalance = await fullNodeSimulator.getBalance([sweepPuzzlehash]);

    // the BTC holder inputs the lightning preimage receipt they receive upon payment of the
    // lightning invoice to sweep funds
    // the payment hash is the hash of the preimage
    final sweepPreimage =
        '5c1f10653dc3ff0531b77351dc6676de2e1f5f53c9f0a8867bcb054648f46a32'.hexToBytes();

    final sweepSpendbundle = btcToXchService.createSweepSpendBundle(
      payments: [Payment(chiaswapAddressBalance, sweepPuzzlehash)],
      coinsInput: chiaswapAddressCoins,
      requestorKeychain: btcDisposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      sweepPreimage: sweepPreimage,
      fulfillerPublicKey: xchHolderPublicKey,
    );

    await fullNodeSimulator.pushTransaction(sweepSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final endingSweepAddressBalance = await fullNodeSimulator.getBalance([sweepPuzzlehash]);

    expect(
      endingSweepAddressBalance,
      equals(startingSweepAddressBalance + chiaswapAddressBalance),
    );
  });

  test(
      'should transfer XCH to chiaswap address and fail to sweep funds to BTC holder when preimage is incorrect',
      () async {
    final btcToXchService = BtcToXchService();
    final xchHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    final btcHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    await xchHolder.farmCoins();
    await xchHolder.refreshCoins();

    // generate disposable mnemonic and keychain for user
    final btcDisposableMnemonic = generateMnemonic(strength: 256);
    final btcDisposableKeychainSecret =
        KeychainCoreSecret.fromMnemonic(btcDisposableMnemonic.split(' '));

    final btcWalletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(btcDisposableKeychainSecret.masterPrivateKey, i);
      btcWalletsSetList.add(set1);
    }

    final btcDisposableKeychain = WalletKeychain.fromWalletSets(btcWalletsSetList);

    // xchHolder also has disposable mnemonic and keychain generated for them when they use the
    // exchange service
    final xchDisposableMnemonic = generateMnemonic(strength: 256);
    final xchDisposableKeychainSecret =
        KeychainCoreSecret.fromMnemonic(xchDisposableMnemonic.split(' '));

    final xchWalletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(xchDisposableKeychainSecret.masterPrivateKey, i);
      xchWalletsSetList.add(set1);
    }

    final xchDisposableKeychain = WalletKeychain.fromWalletSets(btcWalletsSetList);

    final xchDisposableKeychainPuzzlehash =
        xchDisposableKeychain.unhardenedMap.values.first.puzzlehash;

    // xchHolder transfers funds to the disposable keychain
    final coins = xchHolder.standardCoins;

    final coinsToSend = coins.sublist(0, 2);
    coins.removeWhere(coinsToSend.contains);

    final coinsValue = coinsToSend.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );
    final amountToSend = (coinsValue * 0.8).round();
    final fee = (coinsValue * 0.1).round();

    final spendBundle = walletService.createSpendBundle(
      payments: [Payment(amountToSend, xchDisposableKeychainPuzzlehash)],
      coinsInput: coinsToSend,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: xchHolder.keychain,
      fee: fee,
    );

    await fullNodeSimulator.pushTransaction(spendBundle);
    await fullNodeSimulator.moveToNextBlock();

    // user inputs signed public key of counter party, which is parsed and validated to ensure that
    // it was generated by our exchange service
    const xchHolderSignedPublicKey =
        'ad6abe3d432ccce5b40995611c4db6d71e2678f142b8635940c32c4b1c35dde7b01ab42581075eaee173aba747373f71_97c0d2c1acea7708df1eb4a75f625ca1fe95a9aa141a86c2e18bdfd1e8716cba2888f6230ea122ce9478a78f8257beaf0dfb81714f4de6337fa671cc29bb2d4e18e9aae31829016fd94f14e99f86a9ad990f2740d02583c6a85dc4b6b0233aaa';
    final xchHolderPublicKey = exchangeService.parseSignedPublicKey(xchHolderSignedPublicKey);

    // user inputs lightning payment request, which is decoded to get the payment hash
    const paymentRequest =
        'lnbc1u1p3huyzkpp5vw6fkrw9lr3pvved40zpp4jway4g4ee6uzsaj208dxqxgm2rtkvqdqqcqzzgxqyz5vqrzjqwnvuc0u4txn35cafc7w94gxvq5p3cu9dd95f7hlrh0fvs46wpvhdrxkxglt5qydruqqqqryqqqqthqqpyrzjqw8c7yfutqqy3kz8662fxutjvef7q2ujsxtt45csu0k688lkzu3ldrxkxglt5qydruqqqqryqqqqthqqpysp5jzgpj4990chtj9f9g2f6mhvgtzajzckx774yuh0klnr3hmvrqtjq9qypqsqkrvl3sqd4q4dm9axttfa6frg7gffguq3rzuvvm2fpuqsgg90l4nz8zgc3wx7gggm04xtwq59vftm25emwp9mtvmvjg756dyzn2dm98qpakw4u8';
    final decodedPaymentRequest = decodeLightningPaymentRequest(paymentRequest);
    final sweepPaymentHash = decodedPaymentRequest.tags.paymentHash;

    // generate address for XCH holder to send funds to
    final chiaswapPuzzleAddress = btcToXchService.generateChiaswapPuzzleAddress(
      requestorKeychain: btcDisposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: xchHolderPublicKey,
    );

    final chiaswapPuzzlehash = chiaswapPuzzleAddress.toPuzzlehash();

    // XCH holder transfers funds from disposable keychain to chiaswap address
    final coinsForChiaswap =
        await fullNodeSimulator.getCoinsByPuzzleHashes([xchDisposableKeychainPuzzlehash]);

    final amountForChiaswap = coinsForChiaswap.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );

    final chiaswapTransferSpendbundle = walletService.createSpendBundle(
      payments: [Payment(amountForChiaswap, chiaswapPuzzlehash)],
      coinsInput: coinsForChiaswap,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: btcDisposableKeychain,
    );
    await fullNodeSimulator.pushTransaction(chiaswapTransferSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final chiaswapAddressBalance = await fullNodeSimulator.getBalance([chiaswapPuzzlehash]);

    final chiaswapAddressCoins =
        await fullNodeSimulator.getCoinsByPuzzleHashes([chiaswapPuzzleAddress.toPuzzlehash()]);

    // user specifies where they want to receive funds
    final sweepPuzzlehash = btcHolder.firstPuzzlehash;

    // the BTC holder inputs an incorrect lightning preimage
    final sweepPreimage = Puzzlehash.zeros().toBytes();

    expect(
      () {
        btcToXchService.createSweepSpendBundle(
          payments: [Payment(chiaswapAddressBalance, sweepPuzzlehash)],
          coinsInput: chiaswapAddressCoins,
          requestorKeychain: btcHolder.keychain,
          sweepPaymentHash: sweepPaymentHash,
          sweepPreimage: sweepPreimage,
          fulfillerPublicKey: xchHolderPublicKey,
        );
      },
      throwsStateError,
    );
  });

  test('should transfer XCH to chiaswap address and sweep funds to BTC holder using private key',
      () async {
    final btcToXchService = BtcToXchService();
    final xchHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    final btcHolder = ChiaEnthusiast(fullNodeSimulator, walletSize: 2);
    await xchHolder.farmCoins();
    await xchHolder.refreshCoins();

    // generate disposable mnemonic and keychain for user
    final btcDisposableMnemonic = generateMnemonic(strength: 256);
    final btcDisposableKeychainSecret =
        KeychainCoreSecret.fromMnemonic(btcDisposableMnemonic.split(' '));

    final btcWalletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(btcDisposableKeychainSecret.masterPrivateKey, i);
      btcWalletsSetList.add(set1);
    }

    final btcDisposableKeychain = WalletKeychain.fromWalletSets(btcWalletsSetList);

    // xchHolder also has disposable mnemonic and keychain generated for them when they use the
    // exchange service
    final xchDisposableMnemonic = generateMnemonic(strength: 256);
    final xchDisposableKeychainSecret =
        KeychainCoreSecret.fromMnemonic(xchDisposableMnemonic.split(' '));

    final xchWalletsSetList = <WalletSet>[];
    for (var i = 0; i < 5; i++) {
      final set1 = WalletSet.fromPrivateKey(xchDisposableKeychainSecret.masterPrivateKey, i);
      xchWalletsSetList.add(set1);
    }

    final xchDisposableKeychain = WalletKeychain.fromWalletSets(btcWalletsSetList);

    final xchDisposableKeychainWalletVector = xchDisposableKeychain.unhardenedMap.values.first;

    final xchDisposableKeychainPuzzlehash = xchDisposableKeychainWalletVector.puzzlehash;

    // xchHolder transfers funds to the disposable keychain
    final coins = xchHolder.standardCoins;

    final coinsToSend = coins.sublist(0, 2);
    coins.removeWhere(coinsToSend.contains);

    final coinsValue = coinsToSend.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );
    final amountToSend = (coinsValue * 0.8).round();
    final fee = (coinsValue * 0.1).round();

    final spendBundle = walletService.createSpendBundle(
      payments: [Payment(amountToSend, xchDisposableKeychainPuzzlehash)],
      coinsInput: coinsToSend,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: xchHolder.keychain,
      fee: fee,
    );

    await fullNodeSimulator.pushTransaction(spendBundle);
    await fullNodeSimulator.moveToNextBlock();

    // user inputs signed public key of counter party, which is parsed and validated to ensure that
    // it was generated by our exchange service
    final xchHolderSignedPublicKey = exchangeService.createSignedPublicKey(xchDisposableKeychain);
    final xchHolderPublicKey = exchangeService.parseSignedPublicKey(xchHolderSignedPublicKey);

    // user inputs lightning payment request, which is decoded to get the payment hash
    const paymentRequest =
        'lnbc1u1p3huyzkpp5vw6fkrw9lr3pvved40zpp4jway4g4ee6uzsaj208dxqxgm2rtkvqdqqcqzzgxqyz5vqrzjqwnvuc0u4txn35cafc7w94gxvq5p3cu9dd95f7hlrh0fvs46wpvhdrxkxglt5qydruqqqqryqqqqthqqpyrzjqw8c7yfutqqy3kz8662fxutjvef7q2ujsxtt45csu0k688lkzu3ldrxkxglt5qydruqqqqryqqqqthqqpysp5jzgpj4990chtj9f9g2f6mhvgtzajzckx774yuh0klnr3hmvrqtjq9qypqsqkrvl3sqd4q4dm9axttfa6frg7gffguq3rzuvvm2fpuqsgg90l4nz8zgc3wx7gggm04xtwq59vftm25emwp9mtvmvjg756dyzn2dm98qpakw4u8';
    final decodedPaymentRequest = decodeLightningPaymentRequest(paymentRequest);
    final sweepPaymentHash = decodedPaymentRequest.tags.paymentHash;

    // generate address for XCH holder to send funds to
    final chiaswapPuzzleAddress = btcToXchService.generateChiaswapPuzzleAddress(
      requestorKeychain: btcDisposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPublicKey: xchHolderPublicKey,
    );

    final chiaswapPuzzlehash = chiaswapPuzzleAddress.toPuzzlehash();

    // XCH holder transfers funds from disposable keychain to chiaswap address
    final coinsForChiaswap =
        await fullNodeSimulator.getCoinsByPuzzleHashes([xchDisposableKeychainPuzzlehash]);

    final amountForChiaswap = coinsForChiaswap.fold(
      0,
      (int previousValue, element) => previousValue + element.amount,
    );

    final chiaswapTransferSpendbundle = walletService.createSpendBundle(
      payments: [Payment(amountForChiaswap, chiaswapPuzzlehash)],
      coinsInput: coinsForChiaswap,
      changePuzzlehash: xchHolder.firstPuzzlehash,
      keychain: btcDisposableKeychain,
    );
    await fullNodeSimulator.pushTransaction(chiaswapTransferSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final chiaswapAddressBalance = await fullNodeSimulator.getBalance([chiaswapPuzzlehash]);

    final chiaswapAddressCoins =
        await fullNodeSimulator.getCoinsByPuzzleHashes([chiaswapPuzzleAddress.toPuzzlehash()]);

    // user specifies where they want to receive funds
    final sweepPuzzlehash = btcHolder.firstPuzzlehash;
    final startingSweepAddressBalance = await fullNodeSimulator.getBalance([sweepPuzzlehash]);

    // after the lightning invoice is paid, the XCH holder may share their disposable private key
    // the BTC holder inputs the private key, allowing them to sweep funds from the chiaswap address
    final xchHolderPrivateKey = xchDisposableKeychainWalletVector.childPrivateKey;

    final sweepSpendbundle = btcToXchService.createSweepSpendBundleWithPk(
      payments: [Payment(chiaswapAddressBalance, sweepPuzzlehash)],
      coinsInput: chiaswapAddressCoins,
      requestorKeychain: btcDisposableKeychain,
      sweepPaymentHash: sweepPaymentHash,
      fulfillerPrivateKey: xchHolderPrivateKey,
    );

    await fullNodeSimulator.pushTransaction(sweepSpendbundle);
    await fullNodeSimulator.moveToNextBlock();

    final endingSweepAddressBalance = await fullNodeSimulator.getBalance([sweepPuzzlehash]);

    expect(
      endingSweepAddressBalance,
      equals(startingSweepAddressBalance + chiaswapAddressBalance),
    );
  });
}

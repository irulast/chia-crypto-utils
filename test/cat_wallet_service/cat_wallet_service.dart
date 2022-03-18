import 'package:chia_utils/chia_crypto_utils.dart';
import 'package:chia_utils/src/api/full_node.dart';
import 'package:chia_utils/src/cat/service/wallet.dart';
import 'package:chia_utils/src/cat/transport/transport.dart';
import 'package:chia_utils/src/core/models/payment.dart';
import 'package:test/test.dart';

Future<void> main(List<String> args) async {
  final configurationProvider = ConfigurationProvider()
    ..setConfig(NetworkFactory.configId, {
      'yaml_file_path': 'lib/src/networks/chia/testnet10/config.yaml'
    }
  );

  final context = Context(configurationProvider);
  final blockcahinNetworkLoader = ChiaBlockchainNetworkLoader();
  context.registerFactory(NetworkFactory(blockcahinNetworkLoader.loadfromLocalFileSystem));
  final catWalletService = CatWalletService(context);
  const fullNode = FullNode('http://localhost:4000');
  final catTransport = CatTransport(fullNode);

  const targetAssetIdHex = '625c2184e97576f5df1be46c15b2b8771c79e4e6f0aa42d3bfecaebe733f4b8c';

  final targetAssetId = Puzzlehash.fromHex(targetAssetIdHex);

  const testMnemonic = [
      'elder', 'quality', 'this', 'chalk', 'crane', 'endless',
      'machine', 'hotel', 'unfair', 'castle', 'expand', 'refuse',
      'lizard', 'vacuum', 'embody', 'track', 'crash', 'truth',
      'arrow', 'tree', 'poet', 'audit', 'grid', 'mesh',
  ];

  final masterKeyPair = MasterKeyPair.fromMnemonic(testMnemonic);

  final walletsSetList = <WalletSet>[];
  for (var i = 0; i < 5; i++) {
    final set1 = WalletSet.fromPrivateKey(masterKeyPair.masterPrivateKey, i);
    walletsSetList.add(set1);
  }

  final walletKeychain = WalletKeychain(walletsSetList)
    ..addOuterPuzzleHashesForAssetId(targetAssetId);

  final outerPuzzleHashesToSearchFor = walletKeychain.unhardenedMap.values
    .map((e) => e.assetIdtoOuterPuzzlehash[targetAssetId]!).toList();
  final catCoins = await catTransport.getCatCoinsByOuterPuzzleHashes(outerPuzzleHashesToSearchFor, targetAssetId);
  final standardCoins = await fullNode.getCoinRecordsByPuzzleHashes(walletKeychain.unhardenedMap.values.map((e) => e.puzzlehash).toList());
  // print('standard coin balance: ${standardCoins.fold(0, (int previousValue, element) => previousValue + element.amount)}');
  // print('cat coin balance: ${catCoins.fold(0, (int previousValue, element) => previousValue + element.amount)}');
  // prev  standard: 
  // after standard: 

  // prev  cat: 
  // after cat: 

  print('n cat coins: ${catCoins.length}');

  // final targetPuzzlehash = walletKeychain.unhardenedMap.values.toList()[1].puzzlehash;
  final targetPuzzlehash = Address('txch1ftnx4dxr05mestyguwcys3t23dn767nyd6py8w69l70hxmk7332s5f5zx6').toPuzzlehash();
  final changePuzzlehash = walletKeychain.unhardenedMap.values.toList()[0].puzzlehash;
  
  test('Produces valid spendbundle', () async {
    final payment = Payment(100, targetPuzzlehash);
    final spendBundle = catWalletService.createSpendBundle([payment], catCoins[0], changePuzzlehash, walletKeychain);
    await fullNode.pushTransaction(spendBundle);
  });

  test('Produces valid spendbundle with fee', () async {
    final payment = Payment(100, targetPuzzlehash);
    final spendBundle = catWalletService.createSpendBundle([payment], catCoins[0], changePuzzlehash, walletKeychain, fee: 1000, standardCoinsForFee: [standardCoins[0]]);
    await fullNode.pushTransaction(spendBundle);
  });
}

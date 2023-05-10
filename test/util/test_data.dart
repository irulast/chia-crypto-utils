import 'dart:convert';

import 'package:chia_crypto_utils/chia_crypto_utils.dart';

class TestData {
  // Wallet Data
  static final mnemonic = [
    'elder',
    'quality',
    'this',
    'chalk',
    'crane',
    'endless',
    'machine',
    'hotel',
    'unfair',
    'castle',
    'expand',
    'refuse',
    'lizard',
    'vacuum',
    'embody',
    'track',
    'crash',
    'truth',
    'arrow',
    'tree',
    'poet',
    'audit',
    'grid',
    'mesh',
  ];
  static final keychainSecret = KeychainCoreSecret.fromMnemonic(mnemonic);
  // master public key generated by chia wallet from above mnemonic
  static const chiaFingerprint = 3109357790;
  static const chiaMasterPublicKeyHex =
      '901acd53bf61a63120f15442baf0f2a656267b08ba42c511b9bb543e31c32a9b49a0e0aa5e897bc81878d703fcd889f3';
  static const chiaFarmerPublicKeyHex =
      '8351d5afd1ab40bf37565d25600c9b147dcda344e19d413b2c468316d1efd312f61a1eca02a74f8d5f0d6e79911c23ca';
  static const chiaPoolPublicKeyHex =
      '926c9b71f4cfc3f8a595fc77d7edc509e2f426704489eaba6f86728bc391c628c402e00190ba3617931649d8c53b5520';
  static const chiaFirstAddress =
      Address('txch1v8vergyvwugwv0tmxwnmeecuxh3tat5jaskkunnn79zjz0muds0qlg2szv');
  static final firstWalletSet = WalletSet.fromPrivateKey(keychainSecret.masterPrivateKey, 0);

  // ChiaCoinRecord Data
  static final chiaCoinRecordJson = {
    'coin': {
      'amount': 250000000000,
      'parent_coin_info': '0x27ae41e4649b934ca495991b7852b855000000000000000000000000000000d8',
      'puzzle_hash': '0x0b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454ad'
    },
    'coinbase': true,
    'confirmed_block_index': 217,
    'spent': false,
    'spent_block_index': 0,
    'timestamp': 1653407000
  };
  static final chiaCoinRecordFromJson = ChiaCoinRecord.fromJson(chiaCoinRecordJson);
  static final coinFromChiaCoinRecordJson = Coin.fromChiaCoinRecordJson(chiaCoinRecordJson);

  // Coin Data
  static const parentCoinSpendJson =
      '{"coin": {"parent_coin_info": "88ab5f0a47c96b6dd8e0faa86f6f7711730c7a0f30aaa080a62b27139fa3fcb6", "puzzle_hash": "0b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454ad", "amount": 10000}, "puzzle_reveal": "ff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0a4eb51326d2b1583201e22173c8d0e05a595c73039776ef179b7c40123794ebd43efb93364f5cf3ac3549d7b6851c10dff018080", "solution": "ff80ffff01ffff33ffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454adff82232880ffff34ff8203e880ffff3dffa0ece7df847532f6bebd02f1031133fea2f051d67bd8731b197a0efaae09bf09d180ffff3cffa043512694375995ddd59daf7983537433623c65f027522021a58f7f83dba3420e8080ff8080"}';
  static final parentCoinSpend =
      CoinSpend.fromJson(jsonDecode(parentCoinSpendJson) as Map<String, dynamic>);
  static final standardCoin = Coin(
    confirmedBlockIndex: 16409283,
    spentBlockIndex: 0,
    coinbase: false,
    timestamp: 274829924,
    parentCoinInfo:
        Bytes.fromHex('0ea1f9522c7e365cbc502fa6d7ae90d8a5e43a6e983d0e25797094f0110f19cf'),
    puzzlehash:
        Puzzlehash.fromHex('0b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454ad'),
    amount: 9000,
  );

  // CAT1 Data
  static const cat1Hex = '625c2184e97576f5df1be46c15b2b8771c79e4e6f0aa42d3bfecaebe733f4b8c';
  static final cat1AssetId = Puzzlehash.fromHex(cat1Hex);
  static const cat1ParentCoinSpendJson =
      '{"coin": {"parent_coin_info": "f4151ea2a45da9a31c748f71c866f27d17b91b605aeafa4089c35c685be72f77", "puzzle_hash": "778fd03bdb07f0f99046738bc6981dafacbbc0c09fecce04006576f301b74b12", "amount": 100}, "puzzle_reveal": "ff02ffff01ff02ffff01ff02ff5effff04ff02ffff04ffff04ff05ffff04ffff0bff2cff0580ffff04ff0bff80808080ffff04ffff02ff17ff2f80ffff04ff5fffff04ffff02ff2effff04ff02ffff04ff17ff80808080ffff04ffff0bff82027fff82057fff820b7f80ffff04ff81bfffff04ff82017fffff04ff8202ffffff04ff8205ffffff04ff820bffff80808080808080808080808080ffff04ffff01ffffffff81ca3dff46ff0233ffff3c04ff01ff0181cbffffff02ff02ffff03ff05ffff01ff02ff32ffff04ff02ffff04ff0dffff04ffff0bff22ffff0bff2cff3480ffff0bff22ffff0bff22ffff0bff2cff5c80ff0980ffff0bff22ff0bffff0bff2cff8080808080ff8080808080ffff010b80ff0180ffff02ffff03ff0bffff01ff02ffff03ffff09ffff02ff2effff04ff02ffff04ff13ff80808080ff820b9f80ffff01ff02ff26ffff04ff02ffff04ffff02ff13ffff04ff5fffff04ff17ffff04ff2fffff04ff81bfffff04ff82017fffff04ff1bff8080808080808080ffff04ff82017fff8080808080ffff01ff088080ff0180ffff01ff02ffff03ff17ffff01ff02ffff03ffff20ff81bf80ffff0182017fffff01ff088080ff0180ffff01ff088080ff018080ff0180ffff04ffff04ff05ff2780ffff04ffff10ff0bff5780ff778080ff02ffff03ff05ffff01ff02ffff03ffff09ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff01818f80ffff01ff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ffff04ff81b9ff82017980ff808080808080ffff01ff02ff5affff04ff02ffff04ffff02ffff03ffff09ff11ff7880ffff01ff04ff78ffff04ffff02ff36ffff04ff02ffff04ff13ffff04ff29ffff04ffff0bff2cff5b80ffff04ff2bff80808080808080ff398080ffff01ff02ffff03ffff09ff11ff2480ffff01ff04ff24ffff04ffff0bff20ff2980ff398080ffff010980ff018080ff0180ffff04ffff02ffff03ffff09ff11ff7880ffff0159ff8080ff0180ffff04ffff02ff7affff04ff02ffff04ff0dffff04ff0bffff04ff17ff808080808080ff80808080808080ff0180ffff01ff04ff80ffff04ff80ff17808080ff0180ffffff02ffff03ff05ffff01ff04ff09ffff02ff26ffff04ff02ffff04ff0dffff04ff0bff808080808080ffff010b80ff0180ff0bff22ffff0bff2cff5880ffff0bff22ffff0bff22ffff0bff2cff5c80ff0580ffff0bff22ffff02ff32ffff04ff02ffff04ff07ffff04ffff0bff2cff2c80ff8080808080ffff0bff2cff8080808080ffff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff2effff04ff02ffff04ff09ff80808080ffff02ff2effff04ff02ffff04ff0dff8080808080ffff01ff0bff2cff058080ff0180ffff04ffff04ff28ffff04ff5fff808080ffff02ff7effff04ff02ffff04ffff04ffff04ff2fff0580ffff04ff5fff82017f8080ffff04ffff02ff7affff04ff02ffff04ff0bffff04ff05ffff01ff808080808080ffff04ff17ffff04ff81bfffff04ff82017fffff04ffff0bff8204ffffff02ff36ffff04ff02ffff04ff09ffff04ff820affffff04ffff0bff2cff2d80ffff04ff15ff80808080808080ff8216ff80ffff04ff8205ffffff04ff820bffff808080808080808080808080ff02ff2affff04ff02ffff04ff5fffff04ff3bffff04ffff02ffff03ff17ffff01ff09ff2dffff0bff27ffff02ff36ffff04ff02ffff04ff29ffff04ff57ffff04ffff0bff2cff81b980ffff04ff59ff80808080808080ff81b78080ff8080ff0180ffff04ff17ffff04ff05ffff04ff8202ffffff04ffff04ffff04ff24ffff04ffff0bff7cff2fff82017f80ff808080ffff04ffff04ff30ffff04ffff0bff81bfffff0bff7cff15ffff10ff82017fffff11ff8202dfff2b80ff8202ff808080ff808080ff138080ff80808080808080808080ff018080ffff04ffff01a072dec062874cd4d3aab892a0906688a1ae412b0109982e1797a170add88bdcdcffff04ffff01a0'
      '$cat1Hex'
      'ffff04ffff01ff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0b51851c33c513e1d4f0b16534b81e91fb6fd3353384887e94ed53c350295bbbbb909ee9ef26b6ff4e82a96bfc7e364b8ff018080ff0180808080", "solution": "ffff80ffff01ffff3cffa07cc11210514345fcccc45f12135335d51c1ca5ba926fe3f4e070916c1dbd9c2180ffff33ffa06b9af21702cb537ddeaa7c16f44e182099aa3c9354e60fed18a0bacbcccaea4fff8200c880ffff33ffa06b9af21702cb537ddeaa7c16f44e182099aa3c9354e60fed18a0bacbcccaea4fff6480ffff33ffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454adff820d168080ff8080ffffa06f756fb68aeb4a89d6844e57c5778877be620b7bc495b43b3b3f3ff633d01814ffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454adff820d1680ffa019cf756cd15ca67fa80e0da8bba572a03b64c74d6ba111e82826b02d7d43c648ffffa0f4151ea2a45da9a31c748f71c866f27d17b91b605aeafa4089c35c685be72f77ffa0778fd03bdb07f0f99046738bc6981dafacbbc0c09fecce04006576f301b74b12ff6480ffffa0f4151ea2a45da9a31c748f71c866f27d17b91b605aeafa4089c35c685be72f77ffa00b7a3d5e723e0b046fd51f95cabf2d3e2616f05d9d1833e8166052b43d9454adff820d1680ff820ddeff8080"}';
  static final cat1ParentCoinSpend =
      CoinSpend.fromJson(jsonDecode(cat1ParentCoinSpendJson) as Map<String, dynamic>);
  static final validCat1BaseCoin0 = Coin(
    confirmedBlockIndex: 17409283,
    spentBlockIndex: 0,
    coinbase: false,
    timestamp: 2748299274,
    parentCoinInfo:
        Bytes.fromHex('c1fdd54dd268a26fde78bb203a32a14ca942f015a9343d4ea5e9961f997256a1'),
    puzzlehash:
        Puzzlehash.fromHex('778fd03bdb07f0f99046738bc6981dafacbbc0c09fecce04006576f301b74b12'),
    amount: 200,
  );
  static final validCat1Coin0 =
      CatCoin.fromParentSpend(parentCoinSpend: cat1ParentCoinSpend, coin: validCat1BaseCoin0);
  static final invalidCatCoin0 =
      CatCoin.fromParentSpend(parentCoinSpend: cat1ParentCoinSpend, coin: validCat1BaseCoin0);
  static final validCat1BaseCoin1 = Coin(
    confirmedBlockIndex: 17409283,
    spentBlockIndex: 0,
    coinbase: false,
    timestamp: 274829924,
    parentCoinInfo:
        Bytes.fromHex('c1fdd54dd268a26fde78bb203a32a14ca942f015a9343d4ea5e9961f997256a1'),
    puzzlehash:
        Puzzlehash.fromHex('5db372b6e7577013035b4ee3fced2a7466d6ff1d3716b182afe520d83ee3427a'),
    amount: 100,
  );
  static final validCat1Coin1 =
      CatCoin.fromParentSpend(coin: validCat1BaseCoin1, parentCoinSpend: cat1ParentCoinSpend);
  static final cat1Coins = [validCat1Coin0, validCat1Coin1];
  static final cat1Message = [TestData.validCat1Coin0]
      .fold(
        Bytes.empty,
        (Bytes previousValue, coin) => previousValue + coin.id,
      )
      .sha256Hash();
  static final cat1AssertCoinAnnouncementCondition = AssertCoinAnnouncementCondition(
    TestData.validCat1Coin0.id,
    cat1Message,
    morphBytes: Bytes.fromHex('ca'),
  );

  // CAT2 Data
  static const catHex = '0ed71c399419b16df76ae7cde9fa257f1dbf845bef462b7f9ea6de8d181cdf97';
  static final catAssetId = Puzzlehash.fromHex(catHex);
  static const catParentCoinSpendJson =
      '{"coin": {"parent_coin_info": "fe1cecf0d1c5ebce655f8a1c3ff1c532e1a05e60c209e34fbe645d89b9e96bf1", "puzzle_hash": "d9638d7c7e2cebfd7e6c023a5538e7ec7b7259ef85959c873b2c124fd393e67b", "amount": 2200000}, "puzzle_reveal": "ff02ffff01ff02ffff01ff02ff5effff04ff02ffff04ffff04ff05ffff04ffff0bff34ff0580ffff04ff0bff80808080ffff04ffff02ff17ff2f80ffff04ff5fffff04ffff02ff2effff04ff02ffff04ff17ff80808080ffff04ffff02ff2affff04ff02ffff04ff82027fffff04ff82057fffff04ff820b7fff808080808080ffff04ff81bfffff04ff82017fffff04ff8202ffffff04ff8205ffffff04ff820bffff80808080808080808080808080ffff04ffff01ffffffff3d46ff02ff333cffff0401ff01ff81cb02ffffff20ff02ffff03ff05ffff01ff02ff32ffff04ff02ffff04ff0dffff04ffff0bff7cffff0bff34ff2480ffff0bff7cffff0bff7cffff0bff34ff2c80ff0980ffff0bff7cff0bffff0bff34ff8080808080ff8080808080ffff010b80ff0180ffff02ffff03ffff22ffff09ffff0dff0580ff2280ffff09ffff0dff0b80ff2280ffff15ff17ffff0181ff8080ffff01ff0bff05ff0bff1780ffff01ff088080ff0180ffff02ffff03ff0bffff01ff02ffff03ffff09ffff02ff2effff04ff02ffff04ff13ff80808080ff820b9f80ffff01ff02ff56ffff04ff02ffff04ffff02ff13ffff04ff5fffff04ff17ffff04ff2fffff04ff81bfffff04ff82017fffff04ff1bff8080808080808080ffff04ff82017fff8080808080ffff01ff088080ff0180ffff01ff02ffff03ff17ffff01ff02ffff03ffff20ff81bf80ffff0182017fffff01ff088080ff0180ffff01ff088080ff018080ff0180ff04ffff04ff05ff2780ffff04ffff10ff0bff5780ff778080ffffff02ffff03ff05ffff01ff02ffff03ffff09ffff02ffff03ffff09ff11ff5880ffff0159ff8080ff0180ffff01818f80ffff01ff02ff26ffff04ff02ffff04ff0dffff04ff0bffff04ffff04ff81b9ff82017980ff808080808080ffff01ff02ff7affff04ff02ffff04ffff02ffff03ffff09ff11ff5880ffff01ff04ff58ffff04ffff02ff76ffff04ff02ffff04ff13ffff04ff29ffff04ffff0bff34ff5b80ffff04ff2bff80808080808080ff398080ffff01ff02ffff03ffff09ff11ff7880ffff01ff02ffff03ffff20ffff02ffff03ffff09ffff0121ffff0dff298080ffff01ff02ffff03ffff09ffff0cff29ff80ff3480ff5c80ffff01ff0101ff8080ff0180ff8080ff018080ffff0109ffff01ff088080ff0180ffff010980ff018080ff0180ffff04ffff02ffff03ffff09ff11ff5880ffff0159ff8080ff0180ffff04ffff02ff26ffff04ff02ffff04ff0dffff04ff0bffff04ff17ff808080808080ff80808080808080ff0180ffff01ff04ff80ffff04ff80ff17808080ff0180ffff02ffff03ff05ffff01ff04ff09ffff02ff56ffff04ff02ffff04ff0dffff04ff0bff808080808080ffff010b80ff0180ff0bff7cffff0bff34ff2880ffff0bff7cffff0bff7cffff0bff34ff2c80ff0580ffff0bff7cffff02ff32ffff04ff02ffff04ff07ffff04ffff0bff34ff3480ff8080808080ffff0bff34ff8080808080ffff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff2effff04ff02ffff04ff09ff80808080ffff02ff2effff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ffff04ffff04ff30ffff04ff5fff808080ffff02ff7effff04ff02ffff04ffff04ffff04ff2fff0580ffff04ff5fff82017f8080ffff04ffff02ff26ffff04ff02ffff04ff0bffff04ff05ffff01ff808080808080ffff04ff17ffff04ff81bfffff04ff82017fffff04ffff02ff2affff04ff02ffff04ff8204ffffff04ffff02ff76ffff04ff02ffff04ff09ffff04ff820affffff04ffff0bff34ff2d80ffff04ff15ff80808080808080ffff04ff8216ffff808080808080ffff04ff8205ffffff04ff820bffff808080808080808080808080ff02ff5affff04ff02ffff04ff5fffff04ff3bffff04ffff02ffff03ff17ffff01ff09ff2dffff02ff2affff04ff02ffff04ff27ffff04ffff02ff76ffff04ff02ffff04ff29ffff04ff57ffff04ffff0bff34ff81b980ffff04ff59ff80808080808080ffff04ff81b7ff80808080808080ff8080ff0180ffff04ff17ffff04ff05ffff04ff8202ffffff04ffff04ffff04ff78ffff04ffff0eff5cffff02ff2effff04ff02ffff04ffff04ff2fffff04ff82017fff808080ff8080808080ff808080ffff04ffff04ff20ffff04ffff0bff81bfff5cffff02ff2effff04ff02ffff04ffff04ff15ffff04ffff10ff82017fffff11ff8202dfff2b80ff8202ff80ff808080ff8080808080ff808080ff138080ff80808080808080808080ff018080ffff04ffff01a037bef360ee858133b69d595a906dc45d01af50379dad515eb9518abb7c1d2a7affff04ffff01a00ed71c399419b16df76ae7cde9fa257f1dbf845bef462b7f9ea6de8d181cdf97ffff04ffff01ff02ffff01ff02ffff01ff02ffff03ff0bffff01ff02ffff03ffff09ff05ffff1dff0bffff1effff0bff0bffff02ff06ffff04ff02ffff04ff17ff8080808080808080ffff01ff02ff17ff2f80ffff01ff088080ff0180ffff01ff04ffff04ff04ffff04ff05ffff04ffff02ff06ffff04ff02ffff04ff17ff80808080ff80808080ffff02ff17ff2f808080ff0180ffff04ffff01ff32ff02ffff03ffff07ff0580ffff01ff0bffff0102ffff02ff06ffff04ff02ffff04ff09ff80808080ffff02ff06ffff04ff02ffff04ff0dff8080808080ffff01ff0bffff0101ff058080ff0180ff018080ffff04ffff01b0a347236fae530f3d88d8c8e31c144753934afc87465d690249b625c6211a33ffafa7859fea936b4d558f3c9a0454a869ff018080ff0180808080", "solution": "ffff80ffff01ffff33ffa0bae24162efbd568f89bc7a340798a6118df0189eb9e3f8697bcea27af99f8f79ff831e8480ffffa0bae24162efbd568f89bc7a340798a6118df0189eb9e3f8697bcea27af99f8f798080ffff33ffa0fdeb96380a70839c20471530a1ff87953e5e6b0f8244c162e1b95b9e5a6913ecff83030d4080ffff3cffa05f00170220ea8ae31a680e7a8e185d554a63f21eb63388d43c341250084b65c180ffff3fffa07d0a1bdcf9ffdaedc48e54eb55ec3d7318b6c1bc8029c62f5731b19f2f87fa678080ff8080ffffa022843326cad1524573740facdeb9157c2bed5ea8f2db41f7dae05b3a96e337f0ffa08a0000beb0c8cafa2416e41a2960dd9b0da500f2f0f0e0b3ebc1985dfa0aa6dcff8502357fc2e080ffa09e1043ca4182bd46cbeacdcc77e4ec10d98aca0591642aeffa4eb363d3866a7dffffa0fe1cecf0d1c5ebce655f8a1c3ff1c532e1a05e60c209e34fbe645d89b9e96bf1ffa0d9638d7c7e2cebfd7e6c023a5538e7ec7b7259ef85959c873b2c124fd393e67bff832191c080ffffa0fe1cecf0d1c5ebce655f8a1c3ff1c532e1a05e60c209e34fbe645d89b9e96bf1ffa08df97826f24a789c619fac173229a3f943565957735b0d97e0bd742f7167ac7dff832191c080ff80ff8080"}';
  static final catParentCoinSpend =
      CoinSpend.fromJson(jsonDecode(catParentCoinSpendJson) as Map<String, dynamic>);
  static final validCatBaseCoin0 = Coin(
    confirmedBlockIndex: 17409283,
    spentBlockIndex: 0,
    coinbase: false,
    timestamp: 2748299274,
    parentCoinInfo: catParentCoinSpend.coin.id,
    puzzlehash:
        WalletKeychain.makeOuterPuzzleHash(firstWalletSet.unhardened.puzzlehash, catAssetId),
    amount: 200,
  );
  static final validCatCoin0 =
      CatCoin.fromParentSpend(coin: validCatBaseCoin0, parentCoinSpend: catParentCoinSpend);
  static final invalidCat1Coin0 =
      CatCoin.fromParentSpend(coin: validCat1BaseCoin0, parentCoinSpend: catParentCoinSpend);
  static final validCatBaseCoin1 = Coin(
    confirmedBlockIndex: 17409283,
    spentBlockIndex: 0,
    coinbase: false,
    timestamp: 274829924,
    parentCoinInfo: catParentCoinSpend.coin.id,
    puzzlehash:
        WalletKeychain.makeOuterPuzzleHash(firstWalletSet.unhardened.puzzlehash, catAssetId),
    amount: 100,
  );
  static final validCatCoin1 =
      CatCoin.fromParentSpend(coin: validCatBaseCoin1, parentCoinSpend: catParentCoinSpend);
  static final catCoins = [validCatCoin0, validCatCoin1];
  static final catMessage = [TestData.validCatCoin0]
      .fold(
        Bytes.empty,
        (Bytes previousValue, coin) => previousValue + coin.id,
      )
      .sha256Hash();
  static final catAssertCoinAnnouncementCondition = AssertCoinAnnouncementCondition(
    TestData.validCatCoin0.id,
    catMessage,
  );
}
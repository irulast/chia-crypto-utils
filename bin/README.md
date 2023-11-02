# Bin

First clone module with Mozilla's CA cert bundle in the root directory:

```console
git clone https://github.com/Chia-Network/mozilla-ca.git
```

## Full Node URL
A local full node url can be used by providing the path to ssl certificate details

dart bin/chia_crypto_utils.dart Get-CoinRecords --full-node-url https://localhost:8555 --cert-bytes-path ~/.chia/mainnet/config/ssl/full_node/private_full_node.crt --key-bytes-path ~/.chia/mainnet/config/ssl/full_node/private_full_node.key

## Get Coin Records
Use this command to get coin records for a given puzzlehash or address. Only one of these parameters is required.   

```console
dart bin/chia_crypto_utils.dart Get-CoinRecords --full-node-url <FULL_NODE_URL> --puzzlehash <PUZZLEHASH> --address <ADDRESS> 
dart bin/chia_crypto_utils.dart Get-CoinRecords --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --puzzlehash <PUZZLEHASH> --address <ADDRESS> 
```

Can include optional parameter to specify whether to include spent coins, which defaults to false.

```console
dart bin/chia_crypto_utils.dart Get-CoinRecords --full-node-url <FULL_NODE_URL> --puzzlehash <PUZZLEHASH> --address <ADDRESS> --includeSpentCoins 'true'
dart bin/chia_crypto_utils.dart Get-CoinRecords --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --puzzlehash <PUZZLEHASH> --address <ADDRESS> --includeSpentCoins 'true'
```

## Create Wallet With PlotNFT

Use this command to create a wallet with a new plotNFT and register it with a pool. To create a self-pooling plotNFT, omit the pool-url parameter. 

```console
dart bin/chia_crypto_utils.dart Create-WalletWithPlotNFT --full-node-url <FULL_NODE_URL> --faucet-request-url <FAUCET_URL> --faucet-request-payload '{"address": "SEND_TO_ADDRESS", "amount": 0.0000000001}' --pool-url <POOL_URL>
dart bin/chia_crypto_utils.dart Create-WalletWithPlotNFT --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --faucet-request-url <FAUCET_URL> --faucet-request-payload '{"address": "SEND_TO_ADDRESS", "amount": 0.0000000001}' --pool-url <POOL_URL>
```

Can also omit the faucet url and payload if you would like to manually send the XCH needed to create the plotNFT:

```console
dart bin/chia_crypto_utils.dart Create-WalletWithPlotNFT --full-node-url <FULL_NODE_URL> --pool-url <POOL_URL>
dart bin/chia_crypto_utils.dart Create-WalletWithPlotNFT --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --pool-url <POOL_URL>
```

## Mutate PlotNFT

Use this command to leave a pool.

```console
dart bin/chia_crypto_utils.dart Mutate-PlotNFT --full-node-url <FULL_NODE_URL> --faucet-request-url <FAUCET_URL> --faucet-request-payload '{"address": "SEND_TO_ADDRESS", "amount": 0.0000000001}' --mnemonic "mnemonic seed" 
dart bin/chia_crypto_utils.dart Mutate-PlotNFT --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --faucet-request-url <FAUCET_URL> --faucet-request-payload '{"address": "SEND_TO_ADDRESS", "amount": 0.0000000001}' --mnemonic "mnemonic seed"
```

Can also omit the faucet url and payload if you would like to manually send the XCH needed to mutate the plotNFT:

```console
dart bin/chia_crypto_utils.dart Mutate-PlotNFT --full-node-url <FULL_NODE_URL> --mnemonic "mnemonic seed" 
dart bin/chia_crypto_utils.dart Mutate-PlotNFT --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --mnemonic "mnemonic seed" 
```

## Register PlotNFT

Use this command to register a PlotNFT with a pool.

```console
dart bin/chia_crypto_utils.dart Register-PlotNFT --full-node-url <FULL_NODE_URL> --faucet-request-url <FAUCET_URL> --faucet-request-payload '{"address": "SEND_TO_ADDRESS", "amount": 0.0000000001}' --mnemonic "mnemonic seed" --launcher-id <PLOT_NFT_LAUNCHER_ID> --pool-url <POOL_URL>
dart bin/chia_crypto_utils.dart Register-PlotNFT --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --faucet-request-url <FAUCET_URL> --faucet-request-payload '{"address": "SEND_TO_ADDRESS", "amount": 0.0000000001}' --mnemonic "mnemonic seed" --launcher-id <PLOT_NFT_LAUNCHER_ID> --pool-url <POOL_URL>
```

Can also omit the faucet url and payload if you would like to manually send the XCH needed to mutate the plotNFT:

```console
dart bin/chia_crypto_utils.dart Register-PlotNFT --full-node-url <FULL_NODE_URL> --mnemonic "mnemonic seed" --launcher-id <PLOT_NFT_LAUNCHER_ID> --pool-url <POOL_URL>
dart bin/chia_crypto_utils.dart Register-PlotNFT --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE> --mnemonic "mnemonic seed" --launcher-id <PLOT_NFT_LAUNCHER_ID> --pool-url <POOL_URL>
```

## Get Farming Status

Use this command to get the farming status of a mnemonic:

```console
echo "the mnemonic seed" | dart bin/chia_crypto_utils.dart Get-FarmingStatus --full-node-url <FULL_NODE_URL>
echo "the mnemonic seed" | dart bin/chia_crypto_utils.dart Get-FarmingStatus --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE>
```

## Exchange BTC and XCH

Use the below command to initiate an atomic swap between XCH and BTC. You must coordinate with your counter party such that they synchronously run the same command. This feature is adapted from: https://github.com/richardkiss/chiaswap

```console
dart bin/chia_crypto_utils.dart Exchange-Btc --full-node-url <FULL_NODE_URL>
dart bin/chia_crypto_utils.dart Exchange-Btc --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE>
```

## Make Cross Chain Offer File Exchange 

Use the below command to exchange BTC and XCH by creating a new cross chain offer (ccoffer) file or accepting an existing one by creating a ccoffer_accept file. These ccoffer files may be posted to [Dexie](https://dexie.space/markets). An exchange must be completed within a single session. 

```console
dart bin/chia_crypto_utils.dart Make-CrossChainOfferExchange --full-node-url <FULL_NODE_URL>
dart bin/chia_crypto_utils.dart Make-CrossChainOfferExchange --full-node-url <FULL_NODE_URL> --cert-path <PATH_TO_CERT_FILE> --key-path <PATH_TO_KEY_FILE>
```

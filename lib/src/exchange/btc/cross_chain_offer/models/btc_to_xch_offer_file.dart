import 'package:chia_crypto_utils/chia_crypto_utils.dart';
import 'package:chia_crypto_utils/src/exchange/btc/cross_chain_offer/models/cross_chain_offer_exchange_info.dart';
import 'package:chia_crypto_utils/src/exchange/btc/cross_chain_offer/models/cross_chain_offer_file.dart';
import 'package:chia_crypto_utils/src/exchange/btc/cross_chain_offer/models/exchange_amount.dart';
import 'package:chia_crypto_utils/src/exchange/btc/cross_chain_offer/models/xch_to_btc_accept_offer_file.dart';
import 'package:chia_crypto_utils/src/exchange/btc/service/btc_to_xch.dart';

class BtcToXchOfferFile implements CrossChainOfferFile {
  BtcToXchOfferFile({
    required this.offeredAmount,
    required this.requestedAmount,
    required this.messageAddress,
    required this.validityTime,
    required this.publicKey,
  });

  ExchangeAmount offeredAmount;
  ExchangeAmount requestedAmount;
  Address messageAddress;
  @override
  int validityTime;
  @override
  JacobianPoint publicKey;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'offered': offeredAmount.toJson(),
        'requested': requestedAmount.toJson(),
        'message_address': <String, dynamic>{
          'type': messageAddress.prefix,
          'address': messageAddress.address
        },
        'validity_time': validityTime,
        'public_key': publicKey.toHex(),
      };

  factory BtcToXchOfferFile.fromJson(Map<String, dynamic> json) {
    return BtcToXchOfferFile(
      offeredAmount: ExchangeAmount.fromJson(json['offered'] as Map<String, dynamic>),
      requestedAmount: ExchangeAmount.fromJson(json['requested'] as Map<String, dynamic>),
      messageAddress:
          Address((json['message_address'] as Map<String, dynamic>)['address'] as String),
      validityTime: json['validity_time'] as int,
      publicKey: JacobianPoint.fromHexG1(json['public_key'] as String),
    );
  }

  @override
  CrossChainOfferExchangeInfo getExchangeInfo(
    CrossChainOfferFile offerAcceptFile,
    PrivateKey requestorPrivateKey,
  ) {
    final xchToBtcOfferAcceptFile = offerAcceptFile as XchToBtcOfferAcceptFile;

    final amountMojos = requestedAmount.amount;
    final amountSatoshis = offeredAmount.amount;
    final validityTime = xchToBtcOfferAcceptFile.validityTime;
    final paymentRequest = xchToBtcOfferAcceptFile.lightningPaymentRequest;
    final paymentHash = paymentRequest.tags.paymentHash!;
    final fulfillerPublicKey = xchToBtcOfferAcceptFile.publicKey;

    final escrowPuzzlehash = BtcToXchService.generateEscrowPuzzlehash(
      requestorPrivateKey: requestorPrivateKey,
      clawbackDelaySeconds: validityTime,
      sweepPaymentHash: paymentHash,
      fulfillerPublicKey: fulfillerPublicKey,
    );

    return CrossChainOfferExchangeInfo(
      amountMojos: amountMojos,
      amountSatoshis: amountSatoshis,
      escrowPuzzlehash: escrowPuzzlehash,
      paymentRequest: paymentRequest,
    );
  }

  @override
  CrossChainOfferFileType get type => CrossChainOfferFileType.btcToXch;

  @override
  CrossChainOfferFilePrefix get prefix => CrossChainOfferFilePrefix.ccoffer;
}

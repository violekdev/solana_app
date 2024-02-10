import 'package:flutter/material.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_app/home/src/model.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

class Workspace {
  late dynamic wallet;
  late dynamic connection;
  // late dynamic provider;
  late List<ProgramAccount> programList;
  // final clusterUrl = 'https://api.devnet.solana.com';
  final preflightCommitment = Commitment.processed;
  final commitment = Commitment.processed;
  final programPubKey = solanaTweetJSON.metadata['address'] as String;
  final programId = Ed25519HDPublicKey((solanaTweetJSON.metadata['address'] as String).codeUnits);

  Future<void> workspace(SolanaClient solanaClient, AuthorizationResult result) async {
    try {
      // wallet = result.walletUriBase;
      // connection = Connection(Cluster.devnet, commitment: commitment);

      // final anchorInstruction = AnchorInstruction.withDiscriminator(programId: programId, discriminator: ByteArray.u64(8), accounts: solanaTweetJSON.instructions[0]['accounts'] as List<AccountMeta>);

      programList = await solanaClient.rpcClient.getProgramAccounts(programPubKey, encoding: Encoding.base64);
      debugPrint(programList.toString());

      final account = programList[0];
      //programList[0] HRLZyJL2roaN1pSKevdeno8DN6xSvAxtKVLDfoowuFYn
      debugPrint(account.pubkey);

      final accountData = account.account.data! as BinaryAccountData;
      debugPrint(accountData.toString());
      debugPrint(accountData.toJson().toString());
      debugPrint(accountData.data.toString());

      final dataArray = accountData.data;
      final res = String.fromCharCodes(dataArray);
      debugPrint(res);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getTweet(SolanaClient solanaClient, AuthorizationResult result) async {
    await workspace(solanaClient, result);
    // final response = await solanaClient.signTransactions(
    //   transactions: encodedNftTransactions.map((transaction) {
    //     return base64Decode(transaction);
    //   }).toList(),
    // );
    // final transaction = Transaction.fromJson(idl);
    // final sendTransactionResult = await solanaClient.rpcClient.sendTransaction(transaction.encode());
  }
}

final solanaTweetJSON = SolanaTweetJSON(
  version: '0.1.0',
  name: 'solana_twitter',
  instructions: [
    {
      'name': 'sendTweet',
      'accounts': [
        AccountMeta(pubKey: Ed25519HDPublicKey('tweet'.codeUnits), isWriteable: true, isSigner: true),
        AccountMeta(pubKey: Ed25519HDPublicKey('author'.codeUnits), isWriteable: true, isSigner: true),
        AccountMeta(pubKey: Ed25519HDPublicKey('systemProgram'.codeUnits), isWriteable: false, isSigner: false),
      ],
      'args': [
        {'name': 'topic', 'type': 'string'},
        {'name': 'content', 'type': 'string'},
      ],
    },
  ],
  accounts: [
    {
      'name': 'Tweet',
      'type': {
        'kind': 'struct',
        'fields': [
          {'name': 'author', 'type': 'publicKey'},
          {'name': 'timestamp', 'type': 'i64'},
          {'name': 'topic', 'type': 'string'},
          {'name': 'content', 'type': 'string'},
        ],
      },
    },
  ],
  errors: [
    {'code': 6000, 'name': 'TopicTooLong', 'msg': 'The provided topic should be 50 characters long maximum.'},
    {'code': 6001, 'name': 'ContentTooLong', 'msg': 'The provided content should be 280 characters long maximum.'},
  ],
  metadata: {'address': 'DTpzL966JaPFA1VfoyF5CNdYkSoKPLDXqJErpuJvjcTK'},
);

final idl = {
  'version': '0.1.0',
  'name': 'solana_twitter',
  'instructions': [
    {
      'name': 'sendTweet',
      'accounts': [
        {'name': 'tweet', 'isMut': true, 'isSigner': true},
        {'name': 'author', 'isMut': true, 'isSigner': true},
        {'name': 'systemProgram', 'isMut': false, 'isSigner': false},
      ],
      'args': [
        {'name': 'topic', 'type': 'string'},
        {'name': 'content', 'type': 'string'},
      ],
    }
  ],
  'accounts': [
    {
      'name': 'Tweet',
      'type': {
        'kind': 'struct',
        'fields': [
          {'name': 'author', 'type': 'publicKey'},
          {'name': 'timestamp', 'type': 'i64'},
          {'name': 'topic', 'type': 'string'},
          {'name': 'content', 'type': 'string'},
        ],
      },
    }
  ],
  'errors': [
    {'code': 6000, 'name': 'TopicTooLong', 'msg': 'The provided topic should be 50 characters long maximum.'},
    {'code': 6001, 'name': 'ContentTooLong', 'msg': 'The provided content should be 280 characters long maximum.'},
  ],
  'metadata': {'address': 'DTpzL966JaPFA1VfoyF5CNdYkSoKPLDXqJErpuJvjcTK'},
};

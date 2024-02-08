// import 'dart:typed_data';

// import 'package:solana/anchor.dart';
// import 'package:solana/dto.dart';
// import 'package:solana/encoder.dart';
// import 'package:solana/solana.dart' as solana;
// import 'package:solana_app/home/src/model.dart';
// import 'package:solana_mobile_client/solana_mobile_client.dart' as smc;
// import 'package:solana_web3/programs.dart' as programs;
// // import 'package:solana_web3/programs.dart' as s_programs;
// import 'package:solana_web3/solana_web3.dart' as sweb3;

// class Workspace {
//   late dynamic wallet;
//   late dynamic connection;
//   // late dynamic provider;
//   late dynamic program;
//   // final clusterUrl = 'https://api.devnet.solana.com';
//   final preflightCommitment = sweb3.Commitment.processed;
//   final commitment = sweb3.Commitment.processed;
//   final programId = solana.Ed25519HDPublicKey((solanaTweetJSON.metadata['address'] as String).codeUnits);

//   void workspace(solana.SolanaClient solanaClient, smc.AuthorizationResult result) {
//     wallet = result.walletUriBase;
//     connection = sweb3.Connection(sweb3.Cluster.devnet, commitment: commitment);
  
//     final anchorInstruction = AnchorInstruction.withDiscriminator(programId: programId, discriminator: ByteArray.u64(8), accounts: solanaTweetJSON.instructions[0]['accounts'] as List<AccountMeta>);

//     program = programs.;
    
//     // final provider = AnchorProvider(connection, wallet, {preflightCommitment, commitment});
//     // program = Program(idl, programID, provider.value);
    
//     print(program);
//     print(anchorInstruction);
//     print(solanaTweetJSON.instructions[0]['accounts'] as List<AccountMeta>);
//   }

//   Future<void> getTweet(solana.SolanaClient solanaClient, smc.AuthorizationResult result) async {
//     workspace(solanaClient, result);
//     final response = await solanaClient.signTransactions(
//       transactions: encodedNftTransactions.map((transaction) {
//         return base64Decode(transaction);
//       }).toList(),
//     );
//     final transaction = Transaction.fromJson(idl);
//     final sendTransactionResult = await solanaClient.rpcClient.sendTransaction(transaction.encode());
//   }
// }

// final solanaTweetJSON = SolanaTweetJSON(
//   version: '0.1.0',
//   name: 'solana_twitter',
//   instructions: [
//     {
//       'name': 'sendTweet',
//       'accounts': [
//         AccountMeta(pubKey: solana.Ed25519HDPublicKey('tweet'.codeUnits), isWriteable: true, isSigner: true),
//         AccountMeta(pubKey: solana.Ed25519HDPublicKey('author'.codeUnits), isWriteable: true, isSigner: true),
//         AccountMeta(pubKey: solana.Ed25519HDPublicKey('systemProgram'.codeUnits), isWriteable: false, isSigner: false),
//       ],
//       'args': [
//         {'name': 'topic', 'type': 'string'},
//         {'name': 'content', 'type': 'string'},
//       ],
//     },
//   ],
//   accounts: [
//     {
//       'name': 'Tweet',
//       'type': {
//         'kind': 'struct',
//         'fields': [
//           {'name': 'author', 'type': 'publicKey'},
//           {'name': 'timestamp', 'type': 'i64'},
//           {'name': 'topic', 'type': 'string'},
//           {'name': 'content', 'type': 'string'},
//         ],
//       },
//     },
//   ],
//   errors: [
//     {'code': 6000, 'name': 'TopicTooLong', 'msg': 'The provided topic should be 50 characters long maximum.'},
//     {'code': 6001, 'name': 'ContentTooLong', 'msg': 'The provided content should be 280 characters long maximum.'},
//   ],
//   metadata: {'address': 'DTpzL966JaPFA1VfoyF5CNdYkSoKPLDXqJErpuJvjcTK'},
// );

// final idl = {
//   'version': '0.1.0',
//   'name': 'solana_twitter',
//   'instructions': [
//     {
//       'name': 'sendTweet',
//       'accounts': [
//         {'name': 'tweet', 'isMut': true, 'isSigner': true},
//         {'name': 'author', 'isMut': true, 'isSigner': true},
//         {'name': 'systemProgram', 'isMut': false, 'isSigner': false},
//       ],
//       'args': [
//         {'name': 'topic', 'type': 'string'},
//         {'name': 'content', 'type': 'string'},
//       ],
//     }
//   ],
//   'accounts': [
//     {
//       'name': 'Tweet',
//       'type': {
//         'kind': 'struct',
//         'fields': [
//           {'name': 'author', 'type': 'publicKey'},
//           {'name': 'timestamp', 'type': 'i64'},
//           {'name': 'topic', 'type': 'string'},
//           {'name': 'content', 'type': 'string'},
//         ],
//       },
//     }
//   ],
//   'errors': [
//     {'code': 6000, 'name': 'TopicTooLong', 'msg': 'The provided topic should be 50 characters long maximum.'},
//     {'code': 6001, 'name': 'ContentTooLong', 'msg': 'The provided content should be 280 characters long maximum.'},
//   ],
//   'metadata': {'address': 'DTpzL966JaPFA1VfoyF5CNdYkSoKPLDXqJErpuJvjcTK'},
// };

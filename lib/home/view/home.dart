import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:solana/base58.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

class SolanaHomeView extends StatefulWidget {
  const SolanaHomeView({super.key});

  @override
  State<SolanaHomeView> createState() => _SolanaHomeViewState();
}

class _SolanaHomeViewState extends State<SolanaHomeView> {
  late AuthorizationResult? _result;
  int _accountBalance = 0;
  late MobileWalletAdapterClient client;
  final solanaClient = SolanaClient(
    rpcUrl: Uri.parse('https://api.devnet.solana.com'),
    websocketUrl: Uri.parse('wss://api.devnet.solana.com'),
  );
  final int lamportsPerSol = 1000000000;

  @override
  void initState() {
    super.initState();
    (() async {
      _result = null;
      if (!await LocalAssociationScenario.isAvailable()) {
        print('No MWA Compatible wallet available; please install a wallet');
      } else {
        print('FOUND MWA WALLET');
        await authorizeUser();
        await getSOLBalance();
      }
    })();
  }

  Future<void> authorizeUser() async {
    /// step 1
    final localScenario = await LocalAssociationScenario.create();
    try {
      /// step 2
      localScenario.startActivityForResult(null).ignore();

      /// step 3
      client = await localScenario.start();

      /// step 4
      final result = await client.authorize(
        identityUri: Uri.parse('https://solana.apmink.com'),
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'Solana App by Apmink',
        cluster: 'devnet',
      );

      /// step 5
      // await localScenario.close();

      setState(() {
        _result = result;
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    } finally {
      await localScenario.close();
    }
  }

  Future<void> deauthorizeUser() async {
    /// step 1
    // final localScenario = await LocalAssociationScenario.create();
    try {
      /// step 2
      // localScenario.startActivityForResult(null).ignore();

      /// step 3
      // client = await localScenario.start();

      /// step 4
      // final result = await client.authorize(
      //   identityUri: Uri.parse('https://solana.apmink.com'),
      //   iconUri: Uri.parse('favicon.ico'),
      //   identityName: 'Solana App by Apmink',
      //   cluster: 'devnet',
      // );

      await client.deauthorize(authToken: _result!.authToken);

      /// step 5
      // await localScenario.close();

      setState(() {
        _result = null;
        _accountBalance = 0;
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> requestAirDrop() async {
    try {
      await solanaClient.requestAirdrop(
        /// Ed25519HDPublicKey is the main class that represents public
        /// key in the solana dart library
        address: Ed25519HDPublicKey(
          _result!.publicKey.toList(),
        ),
        lamports: 1 * lamportsPerSol,
      );
      await getSOLBalance();
    } catch (e) {
      print('$e');
    }
  }

  Future<void> getSOLBalance() async {
    try {
      debugPrint('get balance');
      final balance = await solanaClient.rpcClient.getBalance(
        base58encode(_result!.publicKey),
      );
      debugPrint('balance${balance.value}');
      setState(() {
        _accountBalance = balance.value;
      });
    } catch (e) {
      print('$e');
    }
  }

  Future<void> generateAndSignTransaction() async {
    final localScenario = await LocalAssociationScenario.create();
    localScenario.startActivityForResult(null).ignore();
    final client = await localScenario.start();
    final reAuth = await client.reauthorize(
      identityUri: Uri.parse('https://solana.com'),
      iconUri: Uri.parse('favicon.ico'),
      identityName: 'Solana',
      authToken: _result!.authToken,
    );

    if (reAuth != null) {
      /// create Memo Program Transaction
      final instruction = MemoInstruction(
        signers: [Ed25519HDPublicKey(_result!.publicKey.toList())],
        memo: 'Example memo',
      );

      final signature = Signature(
        List.filled(64, 0),
        publicKey: Ed25519HDPublicKey(
          _result!.publicKey.toList(),
        ),
      );

      final blockhash = await solanaClient.rpcClient.getLatestBlockhash().then((it) => it.value.blockhash);

      final txn = SignedTx(
        signatures: [signature],
        compiledMessage: Message.only(instruction).compile(
          recentBlockhash: blockhash,
          feePayer: Ed25519HDPublicKey(
            _result!.publicKey.toList(),
          ),
        ),
      );

      final result = await client.signAndSendTransactions(
        transactions: [Uint8List.fromList(txn.toByteArray().toList())],
      );

      await localScenario.close();

      print(
        'TRANSACTION SIGNATURE: https://solscan.io/tx/${base58encode(result.signatures[0])}?cluster=devnet',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Solana Flutter Example'),
          centerTitle: true,
          actions: [
            ElevatedButton(
              onPressed: (_result == null) ? authorizeUser : deauthorizeUser,
              child: Text((_result == null) ? 'Sign in' : 'Sign out'),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Table(
                columnWidths: {0: FixedColumnWidth(screenSize.width * 0.3), 1: FixedColumnWidth(screenSize.width * 0.6)},
                children: [
                  TableRow(
                    children: [
                      const TableCell(child: Text('Public Key')),
                      TableCell(child: Text((_result != null) ? base58encode(_result!.publicKey) : '')),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(child: Text('Account Label')),
                      TableCell(child: Text((_result != null) ? _result!.accountLabel! : '')),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(child: Text('Sol Balance')),
                      TableCell(
                        child: Text(
                          (_accountBalance / lamportsPerSol).toStringAsPrecision(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: screenSize.width * 0.02,
              children: [
                ElevatedButton(
                  onPressed: requestAirDrop,
                  child: const Text('Request Airdrop'),
                ),
                ElevatedButton(
                  onPressed: getSOLBalance,
                  child: const Text('Request Balance'),
                ),
                ElevatedButton(
                  onPressed: generateAndSignTransaction,
                  child: const Text('Generate and Sign Transactions'),
                ),
                // if (_result != null) ElevatedButton(
                //   onPressed:() => workspace.getTweet(solanaClient, _result!),
                //   child: const Text('Get Tweet'),
                // ),
                // MintNFTView(result: _result, solanaClient: solanaClient),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ElevatedButton(
//                 onPressed: () async {
//                   /// step 1
//                   final localScenario = await LocalAssociationScenario.create();

//                   /// step 2
//                   localScenario.startActivityForResult(null).ignore();

//                   /// step 3
//                   final client = await localScenario.start();

//                   /// step 4
//                   final result = await client.authorize(
//                     identityUri: Uri.parse('https://solana.com'),
//                     iconUri: Uri.parse('favicon.ico'),
//                     identityName: 'Solana',
//                     cluster: 'devnet',
//                   );

//                   /// step 5
//                   await localScenario.close();

//                   setState(() {
//                     _result = result;
//                   });
//                 },
//                 child: const Text('Authorize'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await solanaClient.requestAirdrop(
//                       /// Ed25519HDPublicKey is the main class that represents public
//                       /// key in the solana dart library
//                       address: Ed25519HDPublicKey(
//                         _result!.publicKey.toList(),
//                       ),
//                       lamports: 1 * lamportsPerSol,
//                     );
//                   } catch (e) {
//                     print('$e');
//                   }
//                 },
//                 child: const Text('Request Airdrop'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   final localScenario = await LocalAssociationScenario.create();
//                   localScenario.startActivityForResult(null).ignore();
//                   final client = await localScenario.start();
//                   final reAuth = await client.reauthorize(
//                     identityUri: Uri.parse('https://solana.com'),
//                     iconUri: Uri.parse('favicon.ico'),
//                     identityName: 'Solana',
//                     authToken: _result!.authToken,
//                   );

//                   if (reAuth != null) {
//                     /// create Memo Program Transaction
//                     final instruction = MemoInstruction(
//                       signers: [Ed25519HDPublicKey(_result!.publicKey.toList())],
//                       memo: 'Example memo',
//                     );

//                     final signature = Signature(
//                       List.filled(64, 0),
//                       publicKey: Ed25519HDPublicKey(
//                         _result!.publicKey.toList(),
//                       ),
//                     );

//                     final blockhash = await solanaClient.rpcClient.getLatestBlockhash().then((it) => it.value.blockhash);

//                     final txn = SignedTx(
//                       signatures: [signature],
//                       compiledMessage: Message.only(instruction).compile(
//                         recentBlockhash: blockhash,
//                         feePayer: Ed25519HDPublicKey(
//                           _result!.publicKey.toList(),
//                         ),
//                       ),
//                     );

//                     final result = await client.signAndSendTransactions(
//                       transactions: [Uint8List.fromList(txn.toByteArray().toList())],
//                     );

//                     await localScenario.close();

//                     print(
//                       'TRANSACTION SIGNATURE: https://solscan.io/tx/${base58encode(result.signatures[0])}?cluster=devnet',
//                     );
//                   }
//                 },
//                 child: const Text('Generate and Sign Transactions'),
//               ),

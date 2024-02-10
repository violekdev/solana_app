import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solana/base58.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

class MintNFTView extends StatefulWidget {
  const MintNFTView({
    required this.solanaClient,
    required this.result,
    super.key,
  });

  final SolanaClient solanaClient;
  final AuthorizationResult? result;

  @override
  State<MintNFTView> createState() => _MintNFTViewState();
}

class _MintNFTViewState extends State<MintNFTView> {
  final int lamportsPerSol = 1000000000;
  XFile? pickedImage;
  Uint8List pickedImageFile = Uint8List(0);

  TextEditingController nameController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    symbolController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void onSubmit() {
    if (_formKey.currentState!.validate() && pickedImage!.name.isNotEmpty) {}
  }

  Future<void> minNFT() async {
    final localScenario = await LocalAssociationScenario.create();
    localScenario.startActivityForResult(null).ignore();
    final client = await localScenario.start();
    final reAuth = await client.reauthorize(
      identityUri: Uri.parse('https://solana.com'),
      iconUri: Uri.parse('favicon.ico'),
      identityName: 'Solana',
      authToken: widget.result!.authToken,
    );

    if (reAuth != null) {
      /// create Memo Program Transaction
      final instruction = MemoInstruction(
        signers: [Ed25519HDPublicKey(widget.result!.publicKey.toList())],
        memo: 'Example memo',
      );

      final signature = Signature(
        List.filled(64, 0),
        publicKey: Ed25519HDPublicKey(
          widget.result!.publicKey.toList(),
        ),
      );

      final blockhash = await widget.solanaClient.rpcClient.getLatestBlockhash().then((it) => it.value.blockhash);

      final txn = SignedTx(
        signatures: [signature],
        compiledMessage: Message.only(instruction).compile(
          recentBlockhash: blockhash,
          feePayer: Ed25519HDPublicKey(
            widget.result!.publicKey.toList(),
          ),
        ),
      );

      final result = await client.signAndSendTransactions(
        transactions: [Uint8List.fromList(txn.toByteArray().toList())],
      );

      await localScenario.close();

      debugPrint(
        'TRANSACTION SIGNATURE: https://solscan.io/tx/${base58encode(result.signatures[0])}?cluster=devnet',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Center(
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 208,
              height: 208,
              padding: EdgeInsets.zero,
              child: Stack(
                alignment: pickedImageFile.isNotEmpty ? Alignment.topRight : Alignment.center,
                children: [
                  if (pickedImageFile.isNotEmpty)
                    SizedBox(
                      width: 208,
                      height: 208,
                      child: Image.memory(pickedImageFile),
                    ),
                  IconButton(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      XFile? image;
                      //Select Image
                      image = await imagePicker.pickImage(source: ImageSource.gallery, maxHeight: 1024, maxWidth: 1024);
                      final file = await image!.readAsBytes();
                      //Set Image
                      setState(() {
                        pickedImage = image;
                        pickedImageFile = file;
                      });
                    },
                    icon: Icon(pickedImageFile.isNotEmpty ? Icons.edit : Icons.image),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenSize.width * 0.01),
            TextField(
              decoration: const InputDecoration(hintText: 'Name'),
              controller: nameController,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Symbol'),
              controller: symbolController,
            ),
            TextField(
              decoration: const InputDecoration(hintText: 'Description'),
              controller: descriptionController,
              minLines: 2,
              maxLines: 5,
            ),
            const ElevatedButton(
              onPressed: null,
              child: Text('Mint NFT'),
            ),
          ],
        ),
      ),
    );
  }
}

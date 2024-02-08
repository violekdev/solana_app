import 'package:solana/solana.dart';

class Tweet {
  const Tweet({
    required this.publicKey,
    required this.author,
    required this.timestamp,
    required this.topic,
    required this.content,
  });

  final Ed25519HDPublicKey publicKey;
  final Ed25519HDPublicKey author;
  final String timestamp;
  final String topic;
  final String content;

  String get key {
    return publicKey.toBase58();
  }

  String get authorDisplay {
    final authorNew = author.toBase58();
    return '${authorNew.substring(0, 4)}..${authorNew.substring(-4)}';
  }

  String get createdAt {
    return DateTime.parse(timestamp).toIso8601String();
  }

  String get createdAgo {
    return DateTime.parse(timestamp).difference(DateTime.now()).toString();
  }
}

class SolanaTweetJSON {
  const SolanaTweetJSON({
    required this.version,
    required this.name,
    required this.instructions,
    required this.accounts,
    required this.errors,
    required this.metadata,
  });

  final String version;
  final String name;
  final List<dynamic> instructions;
  final List<dynamic> accounts;
  final List<dynamic> errors;
  final Map<String, dynamic> metadata;
}

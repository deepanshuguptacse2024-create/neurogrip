import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Block {
  final int index;
  final String timestamp;
  final String data;
  final String previousHash;
  String hash;

  Block({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
    required this.hash,
  });
}

class BlockchainScreen extends StatefulWidget {
  const BlockchainScreen({super.key});

  @override
  State<BlockchainScreen> createState() => _BlockchainScreenState();
}

class _BlockchainScreenState extends State<BlockchainScreen> {
  List<Block> _chain = [];

  String _calculateHash(int index, String timestamp, String data, String prevHash) {
    final input = '$index$timestamp$data$prevHash';
    return sha256.convert(utf8.encode(input)).toString();
  }

  @override
  void initState() {
    super.initState();
    // Genesis block
    final genesis = Block(
      index: 0,
      timestamp: DateTime.now().toString(),
      data: 'Genesis Block',
      previousHash: '0000',
      hash: '',
    );
    genesis.hash = _calculateHash(0, genesis.timestamp, genesis.data, genesis.previousHash);
    _chain.add(genesis);
  }

  void _addBlock(String data) {
    final prev = _chain.last;
    final newBlock = Block(
      index: _chain.length,
      timestamp: DateTime.now().toString(),
      data: data,
      previousHash: prev.hash,
      hash: '',
    );
    newBlock.hash = _calculateHash(
        newBlock.index, newBlock.timestamp, newBlock.data, newBlock.previousHash);
    setState(() => _chain.add(newBlock));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Records', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0A0E1A),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BCD4),
        onPressed: () => _addBlock(
            'Tremor reading logged at ${DateTime.now().toIso8601String()}'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chain.length,
        itemBuilder: (context, index) {
          final block = _chain[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Block #${block.index}',
                    style: const TextStyle(color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(block.data, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 6),
                Text('Hash: ${block.hash.substring(0, 20)}...',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                Text('Prev: ${block.previousHash.substring(0, 20)}...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}

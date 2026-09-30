import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Product List'),
        ),

        body: const ProductList(),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  late final Future<List<dynamic>> _products = _fetchProducts();

  Future<List<dynamic>> _fetchProducts() async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/products'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Failed to load products: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index] as Map<String, dynamic>;
            final price = (product['price'] as num).toDouble();
            return Card(
              child: ListTile(
                title: Text(product['title']?.toString() ?? 'Unnamed product'),
                subtitle: Text('\$${price.toStringAsFixed(2)}'),
              ),
            );
          },
        );
      },
    );
  }
}
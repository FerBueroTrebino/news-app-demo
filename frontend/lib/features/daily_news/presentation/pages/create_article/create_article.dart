import 'package:flutter/material.dart';

class CreateArticle extends StatelessWidget {
  const CreateArticle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppbar(context),
        body: const Center(child: Text('Create News')));
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Create News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => c.userName.value = v,
              decoration: const InputDecoration(labelText: 'User name'),
            ),
            TextField(
              onChanged: (v) => c.phone.value = v,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              onChanged: (v) => c.password.value = v,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: c.register, child: const Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}

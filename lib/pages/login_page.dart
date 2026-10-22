import 'package:flutter/material.dart';

import '../services/db.dart';
import 'home_page.dart';

/// US#1 : connexion avec un login/password stocké dans la collection `users`.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final login = _login.text.trim();
    final password = _password.text;
    if (login.isEmpty || password.isEmpty) {
      _fail('Login et password sont obligatoires');
      return;
    }

    setState(() => _loading = true);
    try {
      final user = await usersRef.doc(login).get();
      if (!mounted) return;
      if (user.exists && user.data()?['password'] == password) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage(login: login)),
        );
        return;
      }
      _fail('Utilisateur inconnu ou password incorrect : $login');
    } catch (e) {
      _fail('Connexion impossible : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Log console (exigé par le TP) + message à l'écran ; l'application reste utilisable.
  void _fail(String message) {
    debugPrint(message);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MIAGED')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _login,
            decoration: const InputDecoration(labelText: 'Login'),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onSubmitted: (_) => _connect(),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton(
              onPressed: _loading ? null : _connect,
              child: const Text('Se connecter'),
            ),
          ),
        ],
      ),
    );
  }
}

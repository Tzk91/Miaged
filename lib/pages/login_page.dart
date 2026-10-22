import 'package:flutter/material.dart';

import '../services/db.dart';
import '../widgets/centered_body.dart';
import '../widgets/password_field.dart';
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('MIAGED')),
      body: CenteredBody(
        maxWidth: 440,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.local_activity_outlined,
                  size: 44,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bienvenue !',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Connecte-toi pour réserver tes activités',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _login,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Login',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              onSubmitted: (_) => _connect(),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _connect,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

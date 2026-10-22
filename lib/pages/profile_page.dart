import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/db.dart';
import 'add_activity_page.dart';
import 'login_page.dart';

/// US#5 : profil de l'utilisateur, lu et enregistré dans son document `users/{login}`.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.login});

  final String login;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// Champs modifiables du document utilisateur (le login, lui, est son identifiant).
  static const _fields = ['password', 'birthday', 'address', 'postalCode', 'city'];

  final _controllers = {for (final field in _fields) field: TextEditingController()};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = (await usersRef.doc(widget.login).get()).data() ?? {};
      for (final field in _fields) {
        _controllers[field]!.text = '${data[field] ?? ''}';
      }
    } catch (e) {
      debugPrint('Chargement du profil impossible : $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await usersRef.doc(widget.login).update({
        for (final field in _fields) field: _controllers[field]!.text,
      });
      messenger.showSnackBar(const SnackBar(content: Text('Profil enregistré')));
    } catch (e) {
      debugPrint('Enregistrement du profil impossible : $e');
      messenger.showSnackBar(const SnackBar(content: Text("Échec de l'enregistrement")));
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Widget _field(String field, String label, {bool obscure = false, bool digitsOnly = false}) {
    return TextField(
      controller: _controllers[field],
      decoration: InputDecoration(labelText: label),
      obscureText: obscure,
      keyboardType: digitsOnly ? TextInputType.number : null,
      inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _loading ? null : _save,
            child: const Text('Valider'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  initialValue: widget.login,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Login'),
                ),
                _field('password', 'Password', obscure: true),
                _field('birthday', 'Anniversaire'),
                _field('address', 'Adresse'),
                _field('postalCode', 'Code postal', digitsOnly: true),
                _field('city', 'Ville'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddActivityPage()),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une activité'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _logout,
                  child: const Text('Se déconnecter'),
                ),
              ],
            ),
    );
  }
}

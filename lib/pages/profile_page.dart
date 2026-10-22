import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/db.dart';
import '../utils/date_format.dart';
import '../widgets/centered_body.dart';
import '../widgets/password_field.dart';
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
  static const _fields = [
    'password',
    'birthday',
    'address',
    'postalCode',
    'city',
  ];

  final _controllers = {
    for (final field in _fields) field: TextEditingController(),
  };
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
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil enregistré')),
      );
    } catch (e) {
      debugPrint('Enregistrement du profil impossible : $e');
      messenger.showSnackBar(
        const SnackBar(content: Text("Échec de l'enregistrement")),
      );
    }
  }

  Future<void> _pickBirthday() async {
    final controller = _controllers['birthday']!;
    final now = DateTime.now();
    var initial = parseDate(controller.text) ?? DateTime(2000);
    if (initial.isAfter(now) || initial.year < 1900) initial = DateTime(2000);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) controller.text = formatDate(picked);
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  Widget _field(
    String field,
    String label,
    IconData icon, {
    bool digitsOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: _controllers[field],
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      keyboardType: digitsOnly ? TextInputType.number : null,
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const gap = SizedBox(height: 14);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: scheme.onPrimary),
            onPressed: _loading ? null : _save,
            child: const Text('Valider'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CenteredBody(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _ProfileHeader(login: widget.login),
                  const SizedBox(height: 24),
                  TextFormField(
                    initialValue: widget.login,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  gap,
                  PasswordField(controller: _controllers['password']!),
                  gap,
                  _field(
                    'birthday',
                    'Anniversaire',
                    Icons.cake_outlined,
                    onTap: _pickBirthday,
                  ),
                  gap,
                  _field('address', 'Adresse', Icons.home_outlined),
                  gap,
                  _field(
                    'postalCode',
                    'Code postal',
                    Icons.markunread_mailbox_outlined,
                    digitsOnly: true,
                  ),
                  gap,
                  _field('city', 'Ville', Icons.location_city_outlined),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddActivityPage(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une activité'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.error,
                      foregroundColor: scheme.onError,
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.login});

  final String login;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Text(
            login.isEmpty ? '?' : login[0].toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          login,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

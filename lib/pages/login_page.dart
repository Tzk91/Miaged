import 'package:flutter/material.dart';

import '../services/db.dart';
import '../theme.dart';
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
    // En-tête proportionné à l'écran, jamais trop bas pour son contenu.
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.42).clamp(
      280.0,
      400.0,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('MIAGED'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 6,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              _LoginHero(height: heroHeight),
              Padding(
                // La carte du formulaire chevauche le bas de l'en-tête.
                padding: EdgeInsets.only(top: heroHeight - 64),
                child: CenteredBody(
                  maxWidth: 460,
                  shrinkWrap: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: _form(theme),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _form(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Connexion',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Accédez aux activités et à votre panier',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _login,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Login',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              PasswordField(
                controller: _password,
                onSubmitted: (_) => _connect(),
              ),
              const SizedBox(height: 24),
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
      ),
    );
  }
}

/// En-tête de connexion : dégradé « Méditerranée », formes décoratives et bas en vague.
class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: _disc(220, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: 30,
              left: -60,
              child: _disc(160, AppColors.coral.withValues(alpha: 0.35)),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                // Place pour la barre de titre en haut et la carte en bas.
                padding: const EdgeInsets.fromLTRB(24, kToolbarHeight, 24, 72),
                child: Center(
                  // Réduit le contenu plutôt que de déborder (petits écrans, grands textes).
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_activity_outlined,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bienvenue !',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Réservez vos prochaines activités',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _disc(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Bas de l'en-tête en forme de vague.
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..lineTo(0, h - 36)
      ..quadraticBezierTo(w * 0.25, h, w * 0.5, h - 22)
      ..quadraticBezierTo(w * 0.75, h - 44, w, h - 12)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}

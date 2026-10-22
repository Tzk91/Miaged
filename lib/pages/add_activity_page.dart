import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../services/image_classifier.dart';
import '../theme.dart';
import '../widgets/activity_image.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/category_chip.dart';
import '../widgets/centered_body.dart';
import '../widgets/section_card.dart';

/// US#6 : ajout d'une activité ; la catégorie est déduite de l'image par l'IA
/// (ML Kit sur Android, MobileNet sur le web).
class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _location = TextEditingController();
  final _maxPeople = TextEditingController();
  final _price = TextEditingController();

  /// Image choisie, encodée en base64 pour être stockée dans le document Firestore.
  String? _image;
  bool _analyzing = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _title,
      _category,
      _location,
      _maxPeople,
      _price,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Image réduite pour rester loin de la limite de 1 Mo d'un document Firestore.
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 70,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _image = base64Encode(bytes);
      _category.clear();
      _analyzing = true;
    });

    String category;
    try {
      category = await classifyImage(file.path, bytes);
    } catch (e) {
      debugPrint('Classification impossible : $e');
      category = 'Autre';
    }
    if (!mounted) return;
    setState(() {
      _category.text = category;
      _analyzing = false;
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final image = _image;
    final price = int.tryParse(_price.text);
    final maxPeople = int.tryParse(_maxPeople.text);
    if (image == null ||
        _title.text.trim().isEmpty ||
        _location.text.trim().isEmpty ||
        price == null ||
        maxPeople == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Image, titre, lieu, nombre de personnes et prix sont obligatoires',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await activitiesRef.add(
        Activity(
          title: _title.text.trim(),
          category: _category.text,
          location: _location.text.trim(),
          price: price,
          maxPeople: maxPeople,
          image: image,
        ).toMap(),
      );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Activité ajoutée')));
    } catch (e) {
      debugPrint("Ajout de l'activité impossible : $e");
      messenger.showSnackBar(
        const SnackBar(content: Text("Échec de l'ajout de l'activité")),
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    final busy = _analyzing || _saving;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle activité')),
      body: CenteredBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _ImagePickerTile(image: _image, onTap: busy ? null : _pickImage),
            const SizedBox(height: 20),
            _AiCategoryCard(controller: _category, analyzing: _analyzing),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Informations',
              children: [
                TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                gap,
                TextField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: 'Lieu',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                gap,
                TextField(
                  controller: _maxPeople,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    // Libellé long : réduit plutôt que tronqué sur les petits écrans.
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Nombre de personnes maximum'),
                    ),
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                ),
                gap,
                TextField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Prix (€)',
                    prefixIcon: Icon(Icons.euro),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : _save,
            icon: const Icon(Icons.check),
            label: const Text('Valider'),
          ),
        ),
      ),
    );
  }
}

/// Zone de choix de l'image : invite à choisir une photo, puis l'affiche.
class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({required this.image, required this.onTap});

  final String? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = this.image;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Material(
        color: AppColors.teal.withValues(alpha: 0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.teal.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: cardShadow,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 30,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choisir une image',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "L'IA en déduira la catégorie",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    ActivityImage(image),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FilledButton.tonalIcon(
                        onPressed: onTap,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Changer'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Bloc IA : catégorie détectée automatiquement (champ non éditable).
class _AiCategoryCard extends StatelessWidget {
  const _AiCategoryCard({required this.controller, required this.analyzing});

  final TextEditingController controller;
  final bool analyzing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final category = controller.text;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Catégorie détectée par l'IA",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(
                  categoryIcon(category),
                  color: category.isEmpty ? null : categoryColor(category),
                ),
              ),
            ),
            if (analyzing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 6),
              Text(
                kIsWeb
                    ? "Analyse de l'image… (le premier chargement du modèle MobileNet "
                          'prend quelques secondes)'
                    : "Analyse de l'image…",
                style: muted,
              ),
            ] else if (category.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  kIsWeb
                      ? "Choisissez une image : l'IA (MobileNet, TensorFlow.js) en déduit la catégorie."
                      : "Choisissez une image : l'IA (ML Kit) en déduit la catégorie.",
                  style: muted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

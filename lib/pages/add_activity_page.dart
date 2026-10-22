import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/activity.dart';
import '../services/db.dart';
import '../services/image_classifier.dart';
import '../widgets/activity_image.dart';

/// US#6 : ajout d'une activité ; la catégorie est déduite de l'image par l'IA (ML Kit).
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
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [_title, _category, _location, _maxPeople, _price]) {
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
      _category.text = 'Analyse de l’image…';
      _busy = true;
    });

    String category;
    try {
      category = await classifyImage(file.path);
    } catch (e) {
      debugPrint('Classification impossible : $e');
      category = 'Autre';
    }
    if (!mounted) return;
    setState(() {
      _category.text = category;
      _busy = false;
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final price = int.tryParse(_price.text);
    final maxPeople = int.tryParse(_maxPeople.text);
    if (_image == null ||
        _title.text.trim().isEmpty ||
        _location.text.trim().isEmpty ||
        price == null ||
        maxPeople == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Image, titre, lieu, nombre de personnes et prix sont obligatoires'),
      ));
      return;
    }

    setState(() => _busy = true);
    try {
      await activitiesRef.add(Activity(
        title: _title.text.trim(),
        category: _category.text,
        location: _location.text.trim(),
        price: price,
        maxPeople: maxPeople,
        image: _image!,
      ).toMap());
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Activité ajoutée')));
    } catch (e) {
      debugPrint("Ajout de l'activité impossible : $e");
      messenger.showSnackBar(const SnackBar(content: Text("Échec de l'ajout de l'activité")));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle activité'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: _busy ? null : _save,
            child: const Text('Valider'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            onTap: _busy ? null : _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image == null
                  ? Container(
                      height: 180,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 40),
                          SizedBox(height: 8),
                          Text('Choisir une image'),
                        ],
                      ),
                    )
                  : ActivityImage(image, width: double.infinity, height: 180),
            ),
          ),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          TextField(
            controller: _category,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Catégorie (détectée par IA)',
              prefixIcon: Icon(Icons.auto_awesome),
            ),
          ),
          TextField(
            controller: _location,
            decoration: const InputDecoration(labelText: 'Lieu'),
          ),
          TextField(
            controller: _maxPeople,
            decoration: const InputDecoration(labelText: 'Nombre de personnes maximum'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          TextField(
            controller: _price,
            decoration: const InputDecoration(labelText: 'Prix (€)'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }
}

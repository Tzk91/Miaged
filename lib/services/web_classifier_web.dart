import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

/// Fonction définie dans `web/ai_classifier.js` (MobileNet via TensorFlow.js).
@JS('miagedClassify')
external JSPromise<JSString> _miagedClassify(JSString dataUrl);

/// Classes ImageNet reconnues par MobileNet dans le navigateur, avec leur probabilité.
Future<List<(String, double)>> classifyOnWeb(Uint8List bytes) async {
  final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
  final json = (await _miagedClassify(dataUrl.toJS).toDart).toDart;
  return [
    for (final prediction
        in (jsonDecode(json) as List).cast<Map<String, dynamic>>())
      (
        prediction['label'] as String,
        (prediction['confidence'] as num).toDouble(),
      ),
  ];
}

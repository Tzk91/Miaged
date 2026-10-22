// IA de la version web de MIAGED (ML Kit n'existe que sur Android/iOS) :
// MobileNet via TensorFlow.js, téléchargé seulement à la première analyse d'image.
(function () {
  const TFJS_URL = 'https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@4.22.0/dist/tf.min.js';
  const MOBILENET_URL =
    'https://cdn.jsdelivr.net/npm/@tensorflow-models/mobilenet@2.1.1/dist/mobilenet.min.js';
  let modelPromise = null;

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = src;
      script.onload = resolve;
      script.onerror = () => reject(new Error('Chargement impossible : ' + src));
      document.head.appendChild(script);
    });
  }

  function loadModel() {
    if (!modelPromise) {
      modelPromise = loadScript(TFJS_URL)
        .then(() => loadScript(MOBILENET_URL))
        .then(() => window.mobilenet.load())
        .catch((error) => {
          modelPromise = null; // nouvel essai à la prochaine image (ex. réseau revenu)
          throw error;
        });
    }
    return modelPromise;
  }

  /**
   * Classe une image (data URL) avec MobileNet.
   * Renvoie, en JSON, les 5 classes ImageNet les plus probables :
   * [{"label": "canoe", "confidence": 0.61}, ...]
   */
  window.miagedClassify = async function (dataUrl) {
    const model = await loadModel();
    const image = new Image();
    image.src = dataUrl;
    await image.decode();
    const predictions = await model.classify(image, 5);
    return JSON.stringify(
      predictions.map((p) => ({ label: p.className, confidence: p.probability })),
    );
  };
})();

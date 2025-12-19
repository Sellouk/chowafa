import 'dart:math';
import 'package:flutter/services.dart';

class PredictionResult {
  final String text;
  final bool isScary; // True if prediction13 (easter egg)
  
  PredictionResult({required this.text, this.isScary = false});
}

class PredictionService {
  static const String predictionPath = 'predicitons/';
  
  // List of prediction files (matching actual files)
  static const List<String> predictionFiles = [
    'prediction1.txt',
    'prediction2.txt',
    'prediction4.txt',
    'prediction5.txt',
    'prediction6.txt',
    'prediction7.txt',
    'prediction8.txt',
    'prediction9.txt',
    'prediction10.txt',
    'prediction11.txt',
    'prediction12.txt',
    'prediction13.txt',
    'prediction14.txt',
    'prediction15.txt',
    'prediction16.txt',
  ];

  /// Get a random prediction from one of the text files
  /// Returns PredictionResult with isScary=true for prediction13
  Future<PredictionResult> getRandomPrediction() async {
    try {
      final random = Random();
      String randomFile;
      
      // 1% chance for scary prediction13 easter egg
      if (random.nextDouble() < 0.01) {
        randomFile = 'prediction13.txt';
      } else {
        // Get random file excluding prediction13
        final normalFiles = predictionFiles.where((f) => f != 'prediction13.txt').toList();
        randomFile = normalFiles[random.nextInt(normalFiles.length)];
      }
      
      final fullPath = '$predictionPath$randomFile';
      
      // Load text from asset
      final String prediction = await rootBundle.loadString(fullPath);
      
      // Check if this is the scary prediction
      final isScary = randomFile == 'prediction13.txt';
      
      return PredictionResult(
        text: prediction.trim(),
        isScary: isScary,
      );
    } catch (e) {
      return PredictionResult(
        text: 'مستقبلك مليء بالمفاجآت السعيدة والفرص الجديدة. كن مستعداً لاستقبالها بقلب مفتوح.',
        isScary: false,
      );
    }
  }
}

import 'dart:math';

class CardService {
  static const int totalCards = 40;
  static const String cardPath = 'data/cards/';
  
  /// Get list of all card image paths (00.gif to 39.gif)
  List<String> getAllCards() {
    return List.generate(totalCards, (index) {
      String cardNumber = index.toString().padLeft(2, '0');
      return '$cardPath$cardNumber.gif';
    });
  }

  /// Get random selection of cards
  List<String> getRandomCards(int count) {
    final allCards = getAllCards();
    final random = Random();
    
    // Shuffle and take first 'count' cards
    allCards.shuffle(random);
    return allCards.take(count).toList();
  }

  /// Get back of card image path
  String getCardBack() {
    return '${cardPath}back.gif';
  }
}

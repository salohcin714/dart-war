import 'dart:core';
import 'dart:math';

void main() {
  var table = Table(players: ['Nick', 'Eric', 'Daniel']);
  table.dealCards();
}

class Table {
  List<Player> players = [];
  Deck deck = Deck();
  int rounds = 0;

  Table({List<String> players}) {
    for (var player in players) {
      this.players.add(Player(name: player, hand: Hand()));
    }
  }

  void dealCards() {
    deck.shuffle();
    deck.setupHands(players: players);
    for (var player in players) {
      player.showHand();
    }
  }

  playOnce({bool tied = false}) {
  //   if (tied) {
  //     countRound();
  //   }
  //   var collection = Pot();
  //   for (var play)
  }
}

class Player {
  String name;
  Hand hand;

  Player({this.name, this.hand});

  void dropCard({Pot collection}) {
    if (hand.hasCards()) {
      collection.addCard(hand.takeTop(), this);
    }
  }

  void dropBonus(Pot collection, int count) {
    var addedCards = hand.cards.take(count);
    collection.addBonus(cards: addedCards);
    hand.cards.removeWhere((card) => addedCards.contains(card));
  }

  void giveCards(List<Card> cards) {
    hand.addAll(cards: cards);
  }

  void showHand() {
    print('${name} has ${hand}');
  }
}

class Hand {
  List<Card> cards = [];

  @override
  String toString() {
    return cards.join(', ');
  }

  void addCard({Card card}) {
    cards.add(card);
  }

  Card takeTop() {
    var first = cards.first;
    cards.remove(first);
    return first;
  }

  void addAll({List<Card> cards}) {
    this.cards.addAll(cards);
  }

  bool hasCards() {
    return cards.isNotEmpty;
  }
}

class Deck {
  List<String> suits = 'H D S C'.split(' ');
  List<String> ranks = '2 3 4 5 6 7 8 9 10 J Q K A'.split(' ');

  List<Card> cards = [];

  Deck() {
    for (var suit in suits) {
      for (var rank in ranks) {
        cards.add(Card(rank: rank, suit: suit));
      }
    }
  }

  void shuffle() {
    cards.shuffle();
    cards.shuffle();
    cards.shuffle();
  }

  void setupHands({List<Player> players}) {
    var hands = <Hand>[];
    for (var player in players) {
      hands.add(player.hand);
    }
    while (cards.length >= players.length) {
      for (var hand in hands) {
        hand.addCard(card: cards.first);
        cards.remove(cards.first);
      }
    }
  }
}

class Card {
  List<String> suits = 'H D S C'.split(' ');
  List<String> ranks = '2 3 4 5 6 7 8 9 10 J Q K A'.split(' ');

  String suit;
  String rank;

  Card({this.rank, this.suit});

  @override
  String toString() {
    return '${rank}-${suit}';
  }

  int value() {
    return ranks.indexOf(rank);
  }
}

class Pot {
  List<Card> cards = [];
  List<Player> players = [];
  List<Card> bonus = [];
  int best;

  void addCard(Card card, Player player) {
    cards.add(card);
    players.add(player);
  }

  void addBonus({List<Card> cards}) {
    bonus.addAll(cards);
  }

  Player winner() {
    showPot();
    var values = [];
    for (var card in cards) {
      values.add(card.value());
    }
    best = values.reduce(max);
    if (countOccurrences(values, best) == 1) {
      return players[values.indexOf(best)];
    }
  }

  int countOccurrences(List<int> list, int element) {
    if (list == null || list.isEmpty) {
      return 0;
    } else {
      var foundElements = list.where((e) => e == element);
      return foundElements.length;
    }
  }

  void showPot() {
    players.asMap().forEach((index, player) {
      print('${player.name} laid down a ${cards[index]}');
    });
  }

  void reward(Player player) {
    player.giveCards(cards);
    player.giveCards(bonus);
  }

  Player tied() {
    for (var card in cards) {
      if (card.value() == best) {
        return players[cards.indexOf(card)];
      }
    }
  }
}

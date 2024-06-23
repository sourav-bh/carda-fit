class Trophy {
  final int id;
  final String name;
  final String image;

  Trophy({required this.id, required this.name, required this.image});

  static List<Trophy> trophies = [
    Trophy(id: 1, name: "Bronze Booster", image: "assets/images/bronze.png"),
    Trophy(id: 2, name: "Silber Strategen", image: "assets/images/silver.png"),
    Trophy(id: 3, name: "Gold Grinder", image: "assets/images/gold.png"),
    Trophy(
        id: 4, name: "Platin Performer", image: "assets/images/platinum.png"),
    Trophy(id: 5, name: "Diamant Dynamo", image: "assets/images/diamond2.png"),
    Trophy(
        id: 6, name: "Meister Motivator", image: "assets/images/meister.png"),
    Trophy(
        id: 7, name: "Champion Connector", image: "assets/images/champion.png"),
    Trophy(id: 8, name: "Legenden Leader", image: "assets/images/legenden.png"),
    Trophy(id: 9, name: "Elite Enthusiast", image: "assets/images/elite.png"),
  ];
}
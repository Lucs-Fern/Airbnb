class Property {
  final int id;
  final String title;
  final String location;
  final double price;
  final String type;
  final String description;
  final int capacity;
  final String duration;
  final List<String> amenities;
  final bool available;

  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.type,
    required this.description,
    required this.capacity,
    required this.duration,
    required this.amenities,
    required this.available,
  });
}
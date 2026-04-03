class MoodStoreProduct {
  final String moodId;
  final String productId;
  final String title;
  final String description;
  final String price;
  final bool isAvailable;

  const MoodStoreProduct({
    required this.moodId,
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.isAvailable,
  });
}

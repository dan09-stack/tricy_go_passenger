
class FareTier {
  final String id;
  final String name;
  final double price;
  final String eta;
  final String icon;
  final bool isSelected;

  const FareTier({
    required this.id,
    required this.name,
    required this.price,
    required this.eta,
    required this.icon,
    this.isSelected = false,
  });

  FareTier copyWith({
    String? id,
    String? name,
    double? price,
    String? eta,
    String? icon,
    bool? isSelected,
  }) {
    return FareTier(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      eta: eta ?? this.eta,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}


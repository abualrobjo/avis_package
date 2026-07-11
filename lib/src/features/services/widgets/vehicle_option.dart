/// Model for a vehicle/service option in the choose vehicle section.
class VehicleOption {
  const VehicleOption({
    required this.name,
    required this.price,
    required this.eta,
    required this.passengers,
    required this.bags,
    required this.imagePath,
    this.classMiniDesc,
    this.isSoldOut = false,
  });

  final String name;
  final String price;
  final String eta;
  final String imagePath;
  final int passengers;
  final int bags;
  final String? classMiniDesc;
  final bool isSoldOut;
}

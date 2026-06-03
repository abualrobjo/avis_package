class CustomerFavoriteDriversParams {
  final int chauffeurId;
  final int customerId;
  final int tripId;

  const CustomerFavoriteDriversParams({
    required this.chauffeurId,
    required this.customerId,
    required this.tripId,
  });

  Map<String, dynamic> toJson() => {
    'ChauffeurId': chauffeurId,
    'CustomerId': customerId,
    'TripId': tripId,
  };
}

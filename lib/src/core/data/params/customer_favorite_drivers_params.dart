class CustomerFavoriteDriversParams {
  final int chauffeurId;
  final int customerId;

  const CustomerFavoriteDriversParams({
    required this.chauffeurId,
    required this.customerId,
  });

  Map<String, dynamic> toJson() => {
    'ChauffeurId': chauffeurId,
    'CustomerId': customerId,
  };
}

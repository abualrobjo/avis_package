/// responseDetails from BookChauffeurRequest API (contains id to use with GetCustomerTripById).
class BookChauffeurRequestDetails {
  final int id;

  const BookChauffeurRequestDetails({required this.id});

  factory BookChauffeurRequestDetails.fromJson(Map<String, dynamic> json) {
    return BookChauffeurRequestDetails(
      id: (json['id'] as num?)?.toInt() ?? 0,
    );
  }
}

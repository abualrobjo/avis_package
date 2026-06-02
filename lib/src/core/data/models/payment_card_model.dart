import 'package:equatable/equatable.dart';

import 'package:avis_package/src/core/_core.dart';

class PaymentCard extends Equatable {
  final String? id;
  final CardType? type;
  final String? number;
  final String? name;
  final int? month;
  final int? year;
  final int? cvv;
  final bool? isDefault;

  const PaymentCard(
      {this.id,
      this.type,
      this.number,
      this.name,
      this.month,
      this.year,
      this.cvv,
      this.isDefault});

  // copy with
  PaymentCard copyWith({
    String? id,
    CardType? type,
    String? number,
    String? name,
    int? month,
    int? year,
    int? cvv,
    bool? isDefault,
  }) {
    return PaymentCard(
      id: id ?? this.id,
      type: type ?? this.type,
      number: number ?? this.number,
      name: name ?? this.name,
      month: month ?? this.month,
      year: year ?? this.year,
      cvv: cvv ?? this.cvv,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] as String?,
      type: json['type'] != null
          ? CardType.values.byName(json['type'])
          : null, // Fix this line
      number: json['number'] as String?,
      name: json['name'] as String?,
      month: json['month'] as int?,
      year: json['year'] as int?,
      cvv: json['cvv'] as int?,
      isDefault: json['isDefault'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type?.name, // Convert enum to string
      'number': number,
      'name': name,
      'month': month,
      'year': year,
      'cvv': cvv,
      'isDefault': isDefault,
    };
  }

  @override
  String toString() {
    return '[ Id: $id Type: $type, Number: $number, Name: $name, Month: $month, Year: $year, CVV: $cvv, IsDefault: $isDefault ]';
  }

  @override
  List<Object?> get props => [id, type, number, name, month, year, cvv, isDefault];
}

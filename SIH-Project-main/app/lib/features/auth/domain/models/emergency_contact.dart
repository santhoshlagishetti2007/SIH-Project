/// Sanchari Emergency Contact Domain Entity
class EmergencyContact {
  final String? id;
  final String name;
  final String phone;
  final String relation;
  final bool isPrimary;

  const EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    this.relation = 'friend',
    this.isPrimary = false,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relation: json['relation']?.toString() ?? 'friend',
      isPrimary: json['isPrimary'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
      'isPrimary': isPrimary,
    };
  }

  static const List<String> allowedRelations = [
    'parent',
    'spouse',
    'sibling',
    'friend',
    'relative',
    'other',
  ];
}

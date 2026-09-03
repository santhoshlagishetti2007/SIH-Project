class GroupLeadContact {
  final String phone;
  final String email;
  final String whatsapp;

  const GroupLeadContact({
    this.phone = '+919876543210',
    this.email = 'organizer@sanchari.local',
    this.whatsapp = '+919876543210',
  });

  factory GroupLeadContact.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GroupLeadContact();
    return GroupLeadContact(
      phone: json['phone'] as String? ?? '+919876543210',
      email: json['email'] as String? ?? 'organizer@sanchari.local',
      whatsapp: json['whatsapp'] as String? ?? '+919876543210',
    );
  }

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'email': email,
    'whatsapp': whatsapp,
  };
}

class VerificationDetails {
  final String documentType;
  final String documentId;
  final String reviewerNotes;
  final DateTime? verifiedAt;
  final String verifiedBy;

  const VerificationDetails({
    this.documentType = 'Govt ID KYC',
    this.documentId = 'DOC-VERIFIED',
    this.reviewerNotes = 'Verified community organizer identity.',
    this.verifiedAt,
    this.verifiedBy = 'admin_security',
  });

  factory VerificationDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VerificationDetails();
    return VerificationDetails(
      documentType: json['documentType'] as String? ?? 'Govt ID KYC',
      documentId: json['documentId'] as String? ?? 'DOC-VERIFIED',
      reviewerNotes: json['reviewerNotes'] as String? ?? '',
      verifiedAt: json['verifiedAt'] != null ? DateTime.tryParse(json['verifiedAt'].toString()) : null,
      verifiedBy: json['verifiedBy'] as String? ?? 'admin_security',
    );
  }
}

class LocalGroup {
  final String id;
  final String name;
  final String city;
  final String description;
  final String category;
  final String leadName;
  final GroupLeadContact leadContact;
  final int membersCount;
  final int maxMembers;
  final String meetingPoint;
  final String schedule;
  final String coverPhoto;
  final List<String> tags;
  final String verificationStatus; // 'verified' | 'pending' | 'rejected'
  final VerificationDetails verificationDetails;

  const LocalGroup({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    this.category = 'heritage_walk',
    required this.leadName,
    this.leadContact = const GroupLeadContact(),
    this.membersCount = 24,
    this.maxMembers = 100,
    this.meetingPoint = 'City Center',
    this.schedule = 'Every Saturday 7:30 AM',
    this.coverPhoto = 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
    this.tags = const [],
    this.verificationStatus = 'verified',
    this.verificationDetails = const VerificationDetails(),
  });

  bool get isVerified => verificationStatus == 'verified';

  factory LocalGroup.fromJson(Map<String, dynamic> json) {
    return LocalGroup(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? 'Jaipur',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'heritage_walk',
      leadName: json['leadName'] as String? ?? 'Community Lead',
      leadContact: GroupLeadContact.fromJson(json['leadContact'] as Map<String, dynamic>?),
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 24,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 100,
      meetingPoint: json['meetingPoint'] as String? ?? 'City Center',
      schedule: json['schedule'] as String? ?? 'Weekend Morning',
      coverPhoto: json['coverPhoto'] as String? ?? 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      verificationStatus: json['verificationStatus'] as String? ?? 'verified',
      verificationDetails: VerificationDetails.fromJson(json['verificationDetails'] as Map<String, dynamic>?),
    );
  }
}

class JoinRequestResult {
  final bool success;
  final String message;
  final String groupName;
  final String leadName;
  final GroupLeadContact leadContact;

  const JoinRequestResult({
    required this.success,
    required this.message,
    required this.groupName,
    required this.leadName,
    required this.leadContact,
  });

  factory JoinRequestResult.fromJson(Map<String, dynamic> json) {
    return JoinRequestResult(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Request dispatched',
      groupName: json['groupName'] as String? ?? '',
      leadName: json['leadName'] as String? ?? '',
      leadContact: GroupLeadContact.fromJson(json['leadContact'] as Map<String, dynamic>?),
    );
  }
}

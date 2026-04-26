class GarbageJob {
  final String id;
  final String houseId;
  final String ownerName;
  final String address;
  final String mobile;
  final String status;
  final String assignedDate;
  final String? completedDate;
  final String? notes;

  GarbageJob({
    required this.id,
    required this.houseId,
    required this.ownerName,
    required this.address,
    required this.mobile,
    required this.status,
    required this.assignedDate,
    this.completedDate,
    this.notes,
  });

  factory GarbageJob.fromMap(String id, Map<dynamic, dynamic> map) {
    return GarbageJob(
      id: id,
      houseId: map['House_ID']?.toString() ?? '',
      ownerName: map['Owner_Name']?.toString() ?? '',
      address: map['Address']?.toString() ?? '',
      mobile: map['Mobile']?.toString() ?? '',
      status: map['Status']?.toString() ?? 'Pending',
      assignedDate: map['Assigned_Date']?.toString() ?? '',
      completedDate: map['Completed_Date']?.toString(),
      notes: map['Notes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'House_ID': houseId,
      'Owner_Name': ownerName,
      'Address': address,
      'Mobile': mobile,
      'Status': status,
      'Assigned_Date': assignedDate,
      if (completedDate != null) 'Completed_Date': completedDate,
      if (notes != null) 'Notes': notes,
    };
  }

  bool get isPending => status == 'Pending';
  bool get isInProgress => status == 'In_Progress';
  bool get isCompleted => status == 'Completed';
}

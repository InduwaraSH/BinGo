class Job {
  final String fullName;
  final String address;
  final String contact;
  final String type;
  final String weight;
  final DateTime dateCreated;

  Job({
    required this.fullName,
    required this.address,
    required this.contact,
    required this.type,
    required this.weight,
    required this.dateCreated,
  });

  Map<String, String> toMap() {
    return {
      'fullName': fullName,
      'address': address,
      'contact': contact,
      'type': type,
      'weight': weight,
    };
  }
}

// Global list to store jobs
List<Job> jobsList = [];

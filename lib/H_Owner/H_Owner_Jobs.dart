import 'package:flutter/material.dart';

class HOwnerJobs extends StatefulWidget {
  const HOwnerJobs({super.key});

  @override
  State<HOwnerJobs> createState() => _HOwnerJobsState();
}

class _HOwnerJobsState extends State<HOwnerJobs> {
  final List<Map<String, String>> _jobs = [
    {
      'dateLabel': 'Month 24, Year',
      'time': 'WED, 10:00 AM',
      'fullName': 'Jane Doe',
      'address': 'Address',
      'contact': 'Number',
      'type': 'Type',
      'weight': 'Weight',
    },
    {
      'dateLabel': 'Month 24, Year',
      'time': 'WED, 10:00 AM',
      'fullName': 'Jane Doe',
      'address': 'Address',
      'contact': 'Number',
      'type': 'Type',
      'weight': 'Weight',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blue), onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        title: const Text('Jobs', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Profile banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/avatar.png')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        alignment: Alignment.centerLeft,
                        child: const Text('Name', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Jobs list
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final j = _jobs[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Column(
                    children: [
                      const Divider(thickness: 1, color: Colors.blueAccent, height: 2),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(j['dateLabel'] ?? '', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(j['time'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(onPressed: () {/* accept */}, icon: Icon(Icons.check_circle, color: Colors.blue)),
                          IconButton(onPressed: () {/* reject */}, icon: Icon(Icons.cancel, color: Colors.grey.shade400)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Full Name', style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 6),
                                Text('Address', style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 6),
                                Text('Contact No.', style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 6),
                                Text('Type', style: TextStyle(color: Colors.black54)),
                                SizedBox(height: 6),
                                Text('Weight (Kg)', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(j['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(j['address'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(j['contact'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(j['type'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(j['weight'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.blueAccent),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(32)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.chat_bubble_outline, color: Colors.white),
              Icon(Icons.person_outline, color: Colors.white),
              Icon(Icons.calendar_today, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

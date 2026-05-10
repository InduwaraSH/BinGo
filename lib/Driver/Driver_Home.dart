import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class DriverHome extends StatefulWidget {
  final String? username;
  
  const DriverHome({Key? key, this.username}) : super(key: key);

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  DateTime _currentDate = DateTime.now();
  late Timer _dateTimer;

  // Sample data
  final List<Map<String, dynamic>> upcomingJobs = [
    {
      'id': '001',
      'destination': 'Downtown Market',
      'distance': '12.5 km',
      'time': '2:30 PM',
      'status': 'Pending',
      'earnings': '\$45.50',
    },
    {
      'id': '002',
      'destination': 'Airport Terminal 2',
      'distance': '28.3 km',
      'time': '4:15 PM',
      'status': 'Confirmed',
      'earnings': '\$78.00',
    },
    {
      'id': '003',
      'destination': 'Central Station',
      'distance': '8.7 km',
      'time': '5:45 PM',
      'status': 'Pending',
      'earnings': '\$32.25',
    },
  ];

  final List<Map<String, dynamic>> completedJobs = [
    {
      'id': 'C001',
      'destination': 'Shopping Plaza',
      'distance': '15.2 km',
      'completedTime': '1:20 PM',
      'rating': 4.8,
      'earnings': '\$56.75',
    },
    {
      'id': 'C002',
      'destination': 'Business Park',
      'distance': '22.1 km',
      'completedTime': '12:00 PM',
      'rating': 5.0,
      'earnings': '\$89.50',
    },
  ];

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
    final hour12 = (dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12).toString().padLeft(2, '0');
    
    return '${months[dateTime.month - 1]} ${dateTime.day.toString().padLeft(2, '0')}, ${dateTime.year} - $hour12:$minute $ampm';
  }

  String _getDisplayName() {
    if (widget.username == null || widget.username!.isEmpty) {
      return 'Driver';
    }
    
    // If it's an email, extract the part before @
    if (widget.username!.contains('@')) {
      String name = widget.username!.split('@')[0];
      // Convert to title case (capitalize first letter of each word)
      return name.split('.').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
    
    // Otherwise, display as is
    return widget.username ?? 'Driver';
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _dateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentDate = DateTime.now();
      });
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _dateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Date & Profile
                _buildHeaderSection(),
                SizedBox(height: 24),
                // Quick Stats Section
                _buildQuickStatsSection(),
                SizedBox(height: 24),
                // Current Route Section
                _buildCurrentRouteSection(),
                SizedBox(height: 28),
                // Upcoming Jobs Section
                _buildSectionHeader('Upcoming Jobs'),
                _buildUpcomingJobsList(),
                SizedBox(height: 28),
                // Completed Jobs Section
                _buildSectionHeader('Completed Jobs'),
                _buildCompletedJobsList(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2749), Color(0xFF0A0E27)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getDisplayName(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile page coming soon'),
                        backgroundColor: Color(0xFF667DFF),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF667DFF), Color(0xFF5A6FEF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF667DFF).withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Color(0xFF667DFF), size: 18),
                  SizedBox(width: 8),
                  Text(
                    _formatDateTime(_currentDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Settings page coming soon'),
                      backgroundColor: Color(0xFF667DFF),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1F3A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.settings, color: Color(0xFF667DFF), size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Earnings', '\$245.50', Icons.wallet_giftcard)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Rating', '4.8 ⭐', Icons.star)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Trips', '24', Icons.local_shipping)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2E3759), width: 1),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667DFF).withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF667DFF), size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRouteSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667DFF), Color(0xFF5A6FEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667DFF).withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Route',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Live',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Route #RT-2024-001',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Location',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Downtown District, Central Ave',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Destination',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        'Downtown Market - 12.5 km away',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF667DFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingJobsList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          upcomingJobs.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildJobCard(upcomingJobs[index], isCompleted: false),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedJobsList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          completedJobs.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _buildJobCard(completedJobs[index], isCompleted: true),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, {required bool isCompleted}) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job ${job['id']} selected'),
            backgroundColor: Color(0xFF667DFF),
            duration: Duration(milliseconds: 1500),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF2E3759), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isCompleted ? Color(0xFF10B981) : Color(0xFF667DFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            job['destination'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Color(0xFF10B981).withOpacity(0.1)
                                  : job['status'] == 'Confirmed'
                                      ? Color(0xFF667DFF).withOpacity(0.1)
                                      : Color(0xFFFFA500).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              isCompleted ? 'Completed' : job['status'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? Color(0xFF10B981)
                                    : job['status'] == 'Confirmed'
                                        ? Color(0xFF667DFF)
                                        : Color(0xFFFFA500),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.route, size: 12, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            job['distance'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            isCompleted
                                ? job['completedTime']
                                : job['time'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCompleted)
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Color(0xFFFFA500)),
                      SizedBox(width: 4),
                      Text(
                        job['rating'].toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'ID: ${job['id']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                Text(
                  job['earnings'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

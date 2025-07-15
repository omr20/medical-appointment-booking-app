import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointments_list_page.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String imagePath;
  final String service;

  const ServiceDetailsPage({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.imagePath,
    required this.service,
  });

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _availableTimes = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
  ];
  List<String> _filteredTimes = [];

  @override
  void initState() {
    super.initState();
    _filteredTimes = List.from(_availableTimes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
      await fetchAvailableTimes();
    }
  }

  Future<void> fetchAvailableTimes() async {
    if (_selectedDate == null) return;

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: widget.doctorId)
        .where('date', isEqualTo: selectedDateStr)
        .get();

    final bookedTimes = snapshot.docs.map((doc) => doc['time'] as String).toSet();

    setState(() {
      _filteredTimes = _availableTimes.where((time) => !bookedTimes.contains(time)).toList();
    });
  }

  Future<void> _bookAppointment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to book an appointment', style: TextStyle(color: Colors.black)),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushNamed(context, '/signin');
      return;
    }

    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
      final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      try {
        final existingAppointment = await FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: widget.doctorId)
            .where('date', isEqualTo: selectedDateStr)
            .where('time', isEqualTo: _selectedTime)
            .get();

        if (existingAppointment.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This appointment slot is already booked.', style: TextStyle(color: Colors.black)),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('appointments').add({
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
          'specialty': widget.specialty,
          'service': widget.service,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'date': selectedDateStr,
          'time': _selectedTime,
          'userId': user.uid,
          'userEmail': user.email ?? 'Not available',
          'created_at': Timestamp.now(),
          'status': 'pending',
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!', style: TextStyle(color: Colors.black)),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );

        _nameController.clear();
        _phoneController.clear();
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _filteredTimes = List.from(_availableTimes);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: TextStyle(color: Colors.black)),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields', style: TextStyle(color: Colors.black)),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double padding = screenWidth > 600 ? 32.0 : 16.0;
    final double fontSizeTitle = screenWidth > 600 ? 28.0 : 24.0;
    final double fontSizeSubtitle = screenWidth > 600 ? 20.0 : 18.0;
    final double fontSizeText = screenWidth > 600 ? 16.0 : 14.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B4DB).withOpacity(0.4),
            const Color(0xFF8E2DE2).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: Text(
            widget.doctorName,
            style: TextStyle(color: Colors.black, fontSize: fontSizeTitle),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black),
              onPressed: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please sign in to view appointments', style: TextStyle(color: Colors.black)),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pushNamed(context, '/signin');
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsListPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(padding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 8),
                Text('Specialty: ${widget.specialty}',
                    style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black)),
                Text('Service: ${widget.service}',
                    style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black)),
                const SizedBox(height: 24),
                Text('Book Appointment',
                    style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person, color: Colors.black),
                        ),
                        style: TextStyle(fontSize: fontSizeText, color: Colors.black),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number (WhatsApp)',
                          helperText: 'Make sure this number is on WhatsApp',
                          labelStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Colors.black),
                        ),
                        style: TextStyle(fontSize: fontSizeText, color: Colors.black),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your phone number' : null,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.black),
                              const SizedBox(width: 10),
                              Text(
                                _selectedDate == null
                                    ? 'Select Date'
                                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                                style: TextStyle(
                                    color: _selectedDate == null ? Colors.black54 : Colors.black,
                                    fontSize: fontSizeText),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTime,
                        hint: Text('Select Time', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.access_time, color: Colors.black),
                        ),
                        items: _filteredTimes.map((String time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time, style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTime = newValue;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a time' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _bookAppointment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, screenWidth > 600 ? 60 : 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Confirm Booking',
                          style: TextStyle(fontSize: fontSizeText + 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String name;
  final String date;
  final String time;
  final String userId;
  final String userEmail;
  final String phone;
  final Timestamp createdAt;
  final String status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.name,
    required this.date,
    required this.time,
    required this.userId,
    required this.userEmail,
    required this.phone,
    required this.createdAt,
    required this.status,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Appointment(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      specialty: data['specialty'] ?? '',
      name: data['name'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      phone: data['phone'] ?? 'Not provided',
      createdAt: data['created_at'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
    );
  }
}

Stream<List<Appointment>> getAppointmentsStream() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('appointments')
      .where('userId', isEqualTo: user.uid)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
}

class AppointmentsListPage extends StatelessWidget {
  const AppointmentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSizeTitle = screenWidth > 600 ? 20.0 : 18.0;
    final double fontSizeText = screenWidth > 600 ? 16.0 : 14.0;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to view appointments'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/signin');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          title: Text(
            'My Appointments',
            style: TextStyle(fontSize: fontSizeTitle, color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppointmentsListPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Appointment>>(
          stream: getAppointmentsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: fontSizeText, color: Colors.black),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            if (snapshot.data!.isEmpty) {
              return Center(
                child: Text('No appointments found', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data![index];

                Color statusColor;
                switch (appointment.status) {
                  case 'accepted':
                    statusColor = Colors.green;
                    break;
                  case 'rejected':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return Card(
                  margin: const EdgeInsets.all(8),
                  color: Colors.white.withOpacity(0.1),
                  child: ListTile(
                    title: Text(
                      appointment.doctorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeTitle,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Specialty: ${appointment.specialty}', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        Text('Name: ${appointment.name}', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        Text('Email: ${appointment.userEmail}', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        Text('Phone (WhatsApp): ${appointment.phone}', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        Text('Date: ${appointment.date}', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        Text('Time: ${appointment.time}', style: TextStyle(fontSize: fontSizeText, color: Colors.black)),
                        Text(
                          'Status: ${appointment.status}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: fontSizeText,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(appointment.id)
                              .delete();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Appointment canceled successfully', style: TextStyle(color: Colors.black)),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error canceling appointment: $e', style: TextStyle(color: Colors.black)),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _doctorFormKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  String? _selectedSpecialty;
  final List<String> _specialties = [
    'Dental Implants',
    'Dental Fillings',
    'Dental Braces',
    'Teeth Whitening',
    'Scaling and Polishing',
    'Fixed and Removable Prosthetics',
    'Pediatric Dentistry',
    'Hollywood Smile',
  ];

  @override
  void dispose() {
    _doctorNameController.dispose();
    super.dispose();
  }

  Future<void> _askCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission denied'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _askCameraPermission();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      setState(() {
        _isUploading = true;
      });

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('doctor_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_selectedImage!);
      final downloadURL = await storageRef.getDownloadURL();

      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String type) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete $type'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _addDoctor() async {
    if (_doctorFormKey.currentState!.validate()) {
      try {
        final imageUrl = await _uploadImage();

        await FirebaseFirestore.instance.collection('doctors').add({
          'name': _doctorNameController.text.trim(),
          'specialty': _selectedSpecialty,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _doctorNameController.clear();
        setState(() {
          _selectedImage = null;
          _selectedSpecialty = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding doctor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDoctor(String docId) async {
    final confirm = await _confirmDelete(context, 'doctor');
    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('doctors').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting doctor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAppointment(String docId) async {
    final confirm = await _confirmDelete(context, 'appointment');
    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('appointments').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAppointmentStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(docId).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $status'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComment(String docId) async {
    final confirm = await _confirmDelete(context, 'comment');
    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('comments').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSizeTitle = screenWidth > 600 ? 22.0 : 20.0;
    final double fontSizeText = screenWidth > 600 ? 16.0 : 14.0;
    final double padding = screenWidth > 600 ? 32.0 : 16.0;

    if (user == null || user.email != 'admin@example.com') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to access this page!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/landing');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(fontSize: fontSizeTitle)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/signin');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Doctor Section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'Add New Doctor',
                style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _doctorFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo, size: 50),
                            Text('Add Doctor Photo'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _doctorNameController,
                      decoration: InputDecoration(
                        labelText: 'Doctor Name',
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: fontSizeText),
                      ),
                      style: TextStyle(fontSize: fontSizeText),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the doctor\'s name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSpecialty,
                      decoration: InputDecoration(
                        labelText: 'Specialty',
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: fontSizeText),
                      ),
                      hint: Text('Select Specialty', style: TextStyle(fontSize: fontSizeText)),
                      items: _specialties.map((String specialty) {
                        return DropdownMenuItem<String>(
                          value: specialty,
                          child: Text(specialty, style: TextStyle(fontSize: fontSizeText)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSpecialty = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a specialty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isUploading ? null : _addDoctor,
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : Text('Add Doctor', style: TextStyle(fontSize: fontSizeText)),
                    ),
                  ],
                ),
              ),
            ),

            // Doctors Section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'All Doctors',
                style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .orderBy('specialty')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading doctors: ${snapshot.error}', style: TextStyle(fontSize: fontSizeText)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No doctors found', style: TextStyle(fontSize: fontSizeText)));
                }

                // Group doctors by specialty
                Map<String, List<Map<String, dynamic>>> groupedDoctors = {};
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final specialty = data['specialty'] ?? 'Unknown';
                  if (!groupedDoctors.containsKey(specialty)) {
                    groupedDoctors[specialty] = [];
                  }
                  groupedDoctors[specialty]!.add({
                    'id': doc.id,
                    'data': data,
                  });
                }

                return Column(
                  children: groupedDoctors.keys.map((specialty) {
                    return ExpansionTile(
                      title: Text(
                        specialty,
                        style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
                      ),
                      children: groupedDoctors[specialty]!.map((doctor) {
                        final data = doctor['data'];
                        final docId = doctor['id'];
                        String createdAtString = data['createdAt'] != null
                            ? (data['createdAt'] as Timestamp).toDate().toString()
                            : 'Not specified';

                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: data['imageUrl'] != null
                                ? CircleAvatar(
                              backgroundImage: NetworkImage(data['imageUrl']),
                              radius: 30,
                            )
                                : const CircleAvatar(
                              child: Icon(Icons.person),
                              radius: 30,
                            ),
                            title: Text(
                              data['name'] ?? 'Not specified',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeTitle),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Specialty: ${data['specialty'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                                Text('Added: $createdAtString', style: TextStyle(fontSize: fontSizeText)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deleteDoctor(docId);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),

            // Appointments Section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'All Appointments',
                style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading appointments: ${snapshot.error}', style: TextStyle(fontSize: fontSizeText)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No appointments found', style: TextStyle(fontSize: fontSizeText)));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          data['doctorName'] ?? 'Not specified',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeTitle),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Service: ${data['service'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Specialty: ${data['specialty'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Patient: ${data['name'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Email: ${data['userEmail'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Phone (WhatsApp): ${data['phone'] ?? 'Not provided'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Date: ${data['date'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Time: ${data['time'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () async {
                                await _updateAppointmentStatus(doc.id, 'accepted');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.orange),
                              onPressed: () async {
                                await _updateAppointmentStatus(doc.id, 'rejected');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deleteAppointment(doc.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Comments Section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'All Comments',
                style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading comments: ${snapshot.error}', style: TextStyle(fontSize: fontSizeText)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No comments found', style: TextStyle(fontSize: fontSizeText)));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String dateString = data['timestamp'] is Timestamp
                        ? (data['timestamp'] as Timestamp).toDate().toString()
                        : 'Not specified';

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          'Doctor: ${data['doctorName'] ?? 'Not specified'}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeText),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Comment: ${data['content'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('By: ${data['userName'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Date: $dateString', style: TextStyle(fontSize: fontSizeText)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _deleteComment(doc.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
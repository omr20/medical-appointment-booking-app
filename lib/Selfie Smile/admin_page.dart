import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  static const String adminEmail = 'admin@example.com';

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Camera permission is required to take photos.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      } else if (source == ImageSource.gallery) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo library permission is required to select images.'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error accessing ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('doctors_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_imageFile!);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
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

  Future<void> _addDoctor() async {
    if (_formKey.currentState!.validate()) {
      try {
        final imageUrl = await _uploadImage();

        await FirebaseFirestore.instance.collection('doctors').add({
          'name': _nameController.text.trim(),
          'specialty': _specialtyController.text.trim(),
          if (imageUrl != null) 'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser!.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _nameController.clear();
        _specialtyController.clear();
        setState(() {
          _imageFile = null;
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

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this appointment?'),
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
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSizeTitle = screenWidth > 600 ? 22.0 : 20.0;
    final double fontSizeText = screenWidth > 600 ? 16.0 : 14.0;
    final double padding = screenWidth > 600 ? 32.0 : 16.0;

    if (user == null || user.email != AdminPage.adminEmail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to access this page!'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel', style: TextStyle(fontSize: fontSizeTitle)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form to add doctors
            Padding(
              padding: EdgeInsets.all(padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Doctor',
                      style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
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
                    TextFormField(
                      controller: _specialtyController,
                      decoration: InputDecoration(
                        labelText: 'Specialty',
                        border: const OutlineInputBorder(),
                        labelStyle: TextStyle(fontSize: fontSizeText),
                      ),
                      style: TextStyle(fontSize: fontSizeText),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the specialty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.camera),
                          child: Text('Camera', style: TextStyle(fontSize: fontSizeText)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          child: Text('Gallery', style: TextStyle(fontSize: fontSizeText)),
                        ),
                      ],
                    ),
                    if (_imageFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.file(
                          _imageFile!,
                          height: screenWidth > 600 ? 150 : 100,
                          width: screenWidth > 600 ? 150 : 100,
                          fit: BoxFit.cover,
                        ),
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
            // Appointments section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'Appointments',
                style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
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
                            Text('Service: ${data['service'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)), // Added service
                            Text('Specialty: ${data['specialty'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Name: ${data['name'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Email: ${data['userEmail'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Date: ${data['date'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('Time: ${data['time'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('User ID: ${data['userId'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await _confirmDelete(context);
                            if (confirm) {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .delete();
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
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Comments section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                'Comments',
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
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: fontSizeText)));
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
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Doctor: ${data['doctorName'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Comment: ${data['content'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text('By: ${data['userName'] ?? 'Not specified'}', style: TextStyle(fontSize: fontSizeText)),
                            Text(
                              'Date: ${data['timestamp'] != null ? DateTime.parse(data['timestamp']).toLocal().toString() : 'Not specified'}',
                              style: TextStyle(fontSize: fontSizeText),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('comments')
                                  .doc(doc.id)
                                  .delete();
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
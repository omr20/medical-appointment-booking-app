import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_page.dart';
import 'home_screen.dart';
import 'service_details_page.dart';

class DoctorsPage extends StatelessWidget {
  final String? service;

  const DoctorsPage({super.key, this.service});

  static const Map<String, String> serviceMapping = {
    'Tartar Cleaning': 'Scaling and Polishing',
    'Dental Implants': 'Dental Implants',
    'Dental Fillings': 'Dental Fillings',
    'Dental Braces': 'Dental Braces',
    'Teeth Whitening': 'Teeth Whitening',
    'Fixed and Removable Prosthetics': 'Fixed and Removable Prosthetics',
    'Pediatric Dentistry': 'Pediatric Dentistry',
    'Hollywood Smile': 'Hollywood Smile',
  };

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSizeTitle = screenWidth > 600 ? 22.0 : 20.0;
    final double fontSizeSubtitle = screenWidth > 600 ? 16.0 : 14.0;

    final String? selectedSpecialty =
    service != null ? serviceMapping[service] : null;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
              );
            },
          ),
          flexibleSpace: Container(
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
          ),
          title: Text(
            selectedSpecialty ?? 'Doctors',
            style: TextStyle(
              fontSize: fontSizeTitle,
              color: Colors.black, // تغيير إلى الأسود
              shadows: [
                Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: selectedSpecialty != null
                ? FirebaseFirestore.instance
                .collection('doctors')
                .where('specialty', isEqualTo: selectedSpecialty)
                .orderBy('createdAt', descending: true)
                .snapshots()
                : FirebaseFirestore.instance
                .collection('doctors')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: \${snapshot.error}',
                    style:
                    TextStyle(fontSize: fontSizeSubtitle, color: Colors.black), // تغيير إلى الأسود
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.black)); // تغيير إلى الأسود
              }
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    selectedSpecialty != null
                        ? 'No doctors available for \$selectedSpecialty'
                        : 'No doctors available',
                    style:
                    TextStyle(fontSize: fontSizeSubtitle, color: Colors.black), // تغيير إلى الأسود
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return DoctorCard(
                    doctorId: doc.id,
                    doctorName: data['name'] ?? 'Not specified',
                    specialty: data['specialty'] ?? 'Not specified',
                    imageUrl: data['imageUrl'],
                    service: service,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class DoctorCard extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String? imageUrl; // Nullable
  final String? service; // Service parameter

  const DoctorCard({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    this.imageUrl, // Nullable
    this.service,
  });

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _showComments = false;

  Future<void> _addComment() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isSubmitting = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in to add a comment', style: TextStyle(color: Colors.black)), // تغيير إلى الأسود
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('comments').add({
          'doctorId': widget.doctorId,
          'doctorName': widget.doctorName,
          'userId': user.uid,
          'userName': user.displayName ?? 'Anonymous User',
          'userEmail': user.email,
          'content': _commentController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully', style: TextStyle(color: Colors.black)), // تغيير إلى الأسود
            backgroundColor: Colors.green,
          ),
        );
        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e', style: TextStyle(color: Colors.black)), // تغيير إلى الأسود
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSizeTitle = screenWidth > 600 ? 20.0 : 18.0;
    final double fontSizeSubtitle = screenWidth > 600 ? 16.0 : 14.0;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.1), // Semi-transparent background for card
      child: InkWell(
        onTap: () {
          if (widget.service == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a service first', style: TextStyle(color: Colors.black)), // تغيير إلى الأسود
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsPage(
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                specialty: widget.specialty,
                imagePath: widget.imageUrl ?? '', // Use empty string as fallback
                service: widget.service!, // Pass the service, with null check
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widget.imageUrl != null
                      ? CircleAvatar(
                    radius: screenWidth > 600 ? 40 : 30,
                    backgroundImage: NetworkImage(widget.imageUrl!),
                  )
                      : CircleAvatar(
                    radius: screenWidth > 600 ? 40 : 30,
                    child: Icon(Icons.person, size: screenWidth > 600 ? 40 : 30, color: Colors.black), // تغيير إلى الأسود
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeTitle,
                            color: Colors.black, // تغيير إلى الأسود
                          ),
                        ),
                        Text(
                          widget.specialty,
                          style: TextStyle(
                            color: Colors.black, // تغيير إلى الأسود
                            fontSize: fontSizeSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showComments ? Icons.comment : Icons.comment_outlined,
                      color: Colors.black, // تغيير إلى الأسود
                    ),
                    onPressed: () {
                      setState(() {
                        _showComments = !_showComments;
                      });
                    },
                  ),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('doctorId', isEqualTo: widget.doctorId)
                    .snapshots(),
                builder: (context, snapshot) {
                  final commentCount = snapshot.data?.docs.length ?? 0;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _showComments = !_showComments;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'View Comments ($commentCount)',
                            style: TextStyle(
                              color: Colors.black, // تغيير إلى الأسود
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeSubtitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _showComments ? Icons.expand_less : Icons.expand_more,
                            color: Colors.black, // تغيير إلى الأسود
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_showComments) ...[
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(color: Colors.black), // تغيير إلى الأسود
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.black), // تغيير إلى الأسود
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black), // تغيير إلى الأسود
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a comment';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        radius: screenWidth > 600 ? 24 : 20,
                        child: IconButton(
                          icon: _isSubmitting
                              ? const CircularProgressIndicator(
                            color: Colors.black, // تغيير إلى الأسود
                            strokeWidth: 2,
                          )
                              : const Icon(Icons.send, color: Colors.black), // تغيير إلى الأسود
                          onPressed: _isSubmitting ? null : _addComment,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('comments')
                      .where('doctorId', isEqualTo: widget.doctorId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.black)); // تغيير إلى الأسود
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.black)); // تغيير إلى الأسود
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.black), // تغيير إلى الأسود
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) => const Divider(height: 16, color: Colors.black), // تغيير إلى الأسود
                      itemBuilder: (context, index) {
                        final comment = snapshot.data!.docs[index];
                        final commentData = comment.data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    commentData['userName'] ?? 'Anonymous User',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: fontSizeSubtitle,
                                      color: Colors.black, // تغيير إلى الأسود
                                    ),
                                  ),
                                  if (FirebaseAuth.instance.currentUser?.email == AdminPage.adminEmail ||
                                      FirebaseAuth.instance.currentUser?.uid == commentData['userId'])
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.black), // تغيير إلى الأسود
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('comments')
                                              .doc(comment.id)
                                              .delete();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error deleting comment: $e', style: TextStyle(color: Colors.black)), // تغيير إلى الأسود
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                commentData['content'] ?? '',
                                style: TextStyle(fontSize: fontSizeSubtitle - 2, color: Colors.black), // تغيير إلى الأسود
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('yyyy/MM/dd - hh:mm a').format(
                                  DateTime.parse(commentData['timestamp']).toLocal(),
                                ),
                                style: TextStyle(
                                  color: Colors.black, // تغيير إلى الأسود
                                  fontSize: fontSizeSubtitle - 4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_page.dart';
import 'service_details_page.dart';

class DoctorsPage extends StatelessWidget {
  final String? service; // Service parameter from HomeScreen

  const DoctorsPage({super.key, this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
        backgroundColor: Colors.blue[900],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No doctors available'));
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
                  imageUrl: data['imageUrl'] ?? 'https://via.placeholder.com/150',
                  service: service, // Pass the service received
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class DoctorCard extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String imageUrl;
  final String? service; // Service parameter

  const DoctorCard({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.imageUrl,
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
              content: Text('Please sign in to add a comment'),
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
            content: Text('Comment added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
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
      child: InkWell(
        onTap: () {
          if (widget.service == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a service first'),
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
                imagePath: widget.imageUrl,
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
                  CircleAvatar(
                    radius: screenWidth > 600 ? 40 : 30,
                    backgroundImage: NetworkImage(widget.imageUrl),
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
                          ),
                        ),
                        Text(
                          widget.specialty,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: fontSizeSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showComments ? Icons.comment : Icons.comment_outlined,
                      color: Colors.blue[800],
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
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeSubtitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _showComments ? Icons.expand_less : Icons.expand_more,
                            color: Colors.blue[800],
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          style: TextStyle(fontSize: fontSizeSubtitle),
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
                        backgroundColor: Colors.blue[800],
                        radius: screenWidth > 600 ? 24 : 20,
                        child: IconButton(
                          icon: _isSubmitting
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                              : const Icon(Icons.send, color: Colors.white),
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
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      separatorBuilder: (context, index) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final comment = snapshot.data!.docs[index];
                        final commentData = comment.data() as Map<String, dynamic>;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
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
                                    ),
                                  ),
                                  if (FirebaseAuth.instance.currentUser?.email ==
                                      AdminPage.adminEmail ||
                                      FirebaseAuth.instance.currentUser?.uid ==
                                          commentData['userId'])
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18),
                                      color: Colors.red,
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('comments')
                                              .doc(comment.id)
                                              .delete();
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
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                commentData['content'] ?? '',
                                style: TextStyle(fontSize: fontSizeSubtitle - 2),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('yyyy/MM/dd - hh:mm a').format(
                                  DateTime.parse(commentData['timestamp']).toLocal(),
                                ),
                                style: TextStyle(
                                  color: Colors.grey[600],
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
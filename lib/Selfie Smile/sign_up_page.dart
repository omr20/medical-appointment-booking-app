import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': _nameController.text.trim().isNotEmpty
                ? _nameController.text.trim()
                : 'Anonymous',
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign Up successful!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(context, '/signin');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan, Colors.purple],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Join Selfie Smile today',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        color: Colors.white70,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your full name' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      inputType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter your email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    buildInputField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      toggleObscure: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your password' : null,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    buildInputField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      toggleObscure: () => setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please confirm your password' : null,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: screenHeight * 0.065,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.04),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.045,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    TextInputType inputType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyan, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: toggleObscure,
          )
              : null,
        ),
        validator: validator,
      ),
    );
  }
}

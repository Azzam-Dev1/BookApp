import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 40,
            right: 40,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  const Text(
                    "Sign up",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Create your account",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      hintText: "Age",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _genderController,
                    decoration: InputDecoration(
                      hintText: "Gender",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _jobController,
                    decoration: InputDecoration(
                      hintText: "Job",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity, // makes the button take up the full width
                height: 57, // sets a fixed height for the button
                child:ElevatedButton(
                onPressed: () async {
                  if (_passwordController.text == _confirmPasswordController.text) {
                    try {
                      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      if (userCredential.user != null) {
                        await _firestore.collection('users').doc(userCredential.user!.uid).set({
                          'name': _nameController.text,
                          'age': _ageController.text,
                          'gender': _genderController.text,
                          'job': _jobController.text,
                          'email': _emailController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Signup successful!")),
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } catch (e) {
                      String errorMessage;
                      if (e is FirebaseAuthException) {
                        switch (e.code) {
                          case 'email-already-in-use':
                            errorMessage = "The email address is already in use.";
                            break;
                          case 'invalid-email':
                            errorMessage = "The email address is not valid.";
                            break;
                          case 'operation-not-allowed':
                            errorMessage = "Email/password accounts are not enabled.";
                            break;
                          case 'weak-password':
                            errorMessage = "The password is too weak.";
                            break;
                          default:
                            errorMessage = "Signup failed. Please try again.";
                        }
                      } else {
                        errorMessage = "Signup failed: $e";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Passwords do not match")),
                    );
                  }
                },
                child: const Text(
                  "Sign up",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                ),
              ),
              ),
              
              const Center(child: Text("Or")),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.purple,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Google Sign-In successful!")),
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Google Sign-In failed")),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Sign up with Google",
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Image(
                        image: AssetImage("assets/images/google.png"),
                        height: 25.0,
                        width: 25.0,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

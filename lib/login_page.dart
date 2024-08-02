import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(context),
            _inputField(context),
            _forgotPassword(context),
            _signup(context),
          ],
        ),
      ),
    );
  }

  Widget _header(context) {
    return const Column(
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credentials to login"),
      ],
    );
  }

  Widget _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            try {
              UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
              );
              if (userCredential.user != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Login successful!")),
                );
                Navigator.pushReplacementNamed(context, '/home');
              }
            } catch (e) {
              String errorMessage;
              if (e is FirebaseAuthException) {
                switch (e.code) {
                  case 'user-not-found':
                    errorMessage = "No user found for that email.";
                    break;
                  case 'wrong-password':
                    errorMessage = "Wrong password provided for that user.";
                    break;
                  case 'invalid-email':
                    errorMessage = "The email address is not valid.";
                    break;
                  case 'user-disabled':
                    errorMessage = "The user account has been disabled.";
                    break;
                  default:
                    errorMessage = "Login failed. Please try again.";
                }
              } else {
                errorMessage = "Login failed: $e";
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(errorMessage)),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.purple,
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _forgotPassword(context) {
    return TextButton(
      onPressed: () async {
        if (_emailController.text.isNotEmpty) {
          try {
            await _auth.sendPasswordResetEmail(email: _emailController.text);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Password reset email sent")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: $e")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter your email address")),
          );
        }
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.purple),
      ),
    );
  }

  Widget _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.purple),
          ),
        ),
      ],
    );
  }
}

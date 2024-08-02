import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
    setState(() {
      userData = userDoc.data() as Map<String, dynamic>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Header
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(50),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 50, color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            Text(
                              userData!['name'] ?? 'Anonymous',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Profile Details
                    buildProfileDetail(Icons.person, "Name", userData!['name'] ?? 'Not set', textColor),
                    buildProfileDetail(Icons.cake, "Age", userData!['age'] ?? 'Not set', textColor),
                    buildProfileDetail(Icons.person_outline, "Gender", userData!['gender'] ?? 'Not set', textColor),
                    buildProfileDetail(Icons.work, "Job", userData!['job'] ?? 'Not set', textColor),
                    buildProfileDetail(Icons.email, "Email", user!.email ?? 'Not set', textColor),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Navigate to EditProfilePage
                        final updatedUserData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(userData: userData!),
                          ),
                        );

                        // Update the profile with new data
                        if (updatedUserData != null) {
                          setState(() {
                            userData = updatedUserData;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text("Edit Profile", style: TextStyle(fontSize: 18,color:Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildProfileDetail(IconData icon, String title, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 30),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 18, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String age;
  late String gender;
  late String job;

  @override
  void initState() {
    super.initState();
    name = widget.userData['name'] ?? '';
    age = widget.userData['age'] ?? '';
    gender = widget.userData['gender'] ?? '';
    job = widget.userData['job'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                initialValue: age,
                decoration: InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) {
                  age = value!;
                },
              ),
              TextFormField(
                initialValue: gender,
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your gender';
                  }
                  return null;
                },
                onSaved: (value) {
                  gender = value!;
                },
              ),
              TextFormField(
                initialValue: job,
                decoration: InputDecoration(labelText: 'Job'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your job';
                  }
                  return null;
                },
                onSaved: (value) {
                  job = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await _updateUserData();
                    Navigator.pop(context, {
                      'name': name,
                      'age': age,
                      'gender': gender,
                      'job': job,
                    });
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': name,
        'age': age,
        'gender': gender,
        'job': job,
      });
    }
  }
}

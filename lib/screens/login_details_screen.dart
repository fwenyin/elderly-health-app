import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

import '../widget/app_bar.dart';
import 'home_screen.dart';

class LoginDetailsPage extends StatefulWidget {
  @override
  _LoginDetailsPageState createState() => _LoginDetailsPageState();
}

class _LoginDetailsPageState extends State<LoginDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _uploadedFileURL;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      uploadFile();
    } else {
      print('No image selected.');
    }
  }

  Future uploadFile() async {
    if (_image == null) return;
    final fileName = Path.basename(_image!.path);
    final destination = 'profile_pictures/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      final task = ref.putFile(_image!);
      final snapshot = await task.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedFileURL = urlDownload;
      });
    } catch (e) {
      print('error occured');
    }
  }

  void saveUserDetails() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameController.text,
          'age': int.parse(ageController.text),
          'weight': double.parse(weightController.text),
          'height': double.parse(heightController.text),
          'phone': user.phoneNumber,
          'profile_picture': _uploadedFileURL,
        });

        await FirebaseFirestore.instance
            .collection('phoneNumbers')
            .doc(user.phoneNumber)
            .set({
          'uid': user.uid,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture
              if (_image != null) Image.file(_image!, height: 150),
              ElevatedButton(
                onPressed: getImage,
                child: Text("Pick Profile Picture"),
              ),
              // Name input
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              // Age input
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    hintText: 'Age',
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
              ),
              // Weight input
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    hintText: 'Weight (kg)',
                    labelText: 'Weight',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid weight';
                    }
                    return null;
                  },
                ),
              ),
              // Height input
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    hintText: 'Height (cm)',
                    labelText: 'Height',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid height';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: saveUserDetails,
                child: Text("Save Details"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

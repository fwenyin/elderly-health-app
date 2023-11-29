import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

import '../l10n/app_localizations.dart';
import '../widget/app_bar.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  File? _image;
  String? _uploadedFileURL;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        nameController.text = data['name'];
        ageController.text = data['age'].toString();
        weightController.text = data['weight'].toString();
        heightController.text = data['height'].toString();
        _uploadedFileURL = data['profile_picture'];
      });
    }
  }

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

  Future<void> saveUserDetails() async {
    if (_formKey.currentState!.validate()) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': nameController.text,
        'age': int.parse(ageController.text),
        'weight': double.parse(weightController.text),
        'height': double.parse(heightController.text),
        'profile_picture': _uploadedFileURL,
      });

      Navigator.pop(
          context); // Assuming you want to close the edit page after saving
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
            if (_uploadedFileURL != null)
              Image.network(_uploadedFileURL!, height: 150),
            ElevatedButton(
              onPressed: getImage,
              child: Text(AppLocalizations.of(context)!.changePicture),
            ),
            SizedBox(height: 30),
            // Name TextField
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterName;
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Age TextField
            TextFormField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.age,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterAge;
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid age';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Weight TextField
            TextFormField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.weight,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterWeight;
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Height TextField
            TextFormField(
              controller: heightController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.height,
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.enterHeight;
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid height';
                }
                return null;
              },
            ),
            SizedBox(height: 120), 
            // Save Button
            ElevatedButton(
              onPressed: saveUserDetails,
              child: Text(AppLocalizations.of(context)!.saveChanges),
            ),
          ],
        ),
      ),),
    );
  }
}

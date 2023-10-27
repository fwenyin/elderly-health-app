import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String userNumber = '';

  FirebaseAuth auth = FirebaseAuth.instance;

  var otpFieldVisibility = false;
  var receivedID = '';

  void verifyUserPhoneNumber() {
    auth.verifyPhoneNumber(
      phoneNumber: userNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then(
              (value) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              ),
            );
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        receivedID = verificationId;
        otpFieldVisibility = true;
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTPCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: receivedID,
      smsCode: otpController.text,
    );
    await auth
        .signInWithCredential(credential)
        .then((value) => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Phone Authentication',
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IntlPhoneField(
              controller: phoneController,
              initialCountryCode: 'SG',
              decoration: const InputDecoration(
                hintText: 'Phone Number',
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                userNumber = val.completeNumber;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Visibility(
              visible: otpFieldVisibility,
              child: TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  hintText: 'OTP Code',
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (otpFieldVisibility) {
                verifyOTPCode();
              } else {
                verifyUserPhoneNumber();
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Text(
              otpFieldVisibility ? 'Login' : 'Verify',
            ),
          )
        ],
      ),
    );
  }
}

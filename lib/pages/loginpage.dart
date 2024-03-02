import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _verificationId = '';
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final numberController = TextEditingController();

//? Callbacks for phone auth
//TO VERIFIY OTP
  Future<void> _verifyPhoneNumber() async {
    verificationCompleted(PhoneAuthCredential credential) async {
      // Handle automatic verification
      // You can sign in the user with credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('Automatic verification succeeded: ${userCredential.user!.uid}');
    }

// ON FAILED SIGN IN
    verificationFailed(FirebaseAuthException e) {
      print('Phone number verification failed: ${e.message}');
    }

//TO SEND OTP
    codeSent(String verificationId, int? resendToken) async {
      print('Verification code sent to the phone number: $verificationId');
      setState(() {
        _verificationId = verificationId;
      });
    }

//TO AGAIN SEND OTP
    codeAutoRetrievalTimeout(String verificationId) {
      print('Timeout reached while waiting for the verification code.');
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91' + numberController.text,
        // Replace with your phone number
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

//TO SIGN IN
  Future<void> _signInWithPhoneNumber(String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('User signed in: ${userCredential.user!.uid}');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.send),
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error in Form')),
              );
            } else {
              print('ONTO ELSE');

              // positional(a, b)
              // positional(b, a)
              // namedParameter( )

              gotoNextSceen(number: numberController, name: nameController);
              // _verifyPhoneNumber(); // Call _verifyPhoneNumber method
            }
          },
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Name';
                    }
                    return null;
                  },
                  controller: nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Your  Number';
                    }
                    return null;
                  },
                  controller: numberController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter Number'),
                ),
              ],
            ),
          ),
        ));
  }

  // this.toast.open(this.context,"message",Toast.DUATION_SHORT).show()  //Example of function with positional parameter

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    numberController.dispose();
    super.dispose();
  }

  void gotoNextSceen(
      {required TextEditingController name,
      required TextEditingController number}) {
    FirebaseFirestore.instance.collection('users').doc(number.text).set({
      'name': name.text,
      'phone': number.text,
    }).then((value) => {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Data saved!!!')),
    )
    });
  }
}

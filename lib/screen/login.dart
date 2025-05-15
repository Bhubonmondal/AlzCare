import 'package:alzcare/data/quotes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/textfield_design.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isObscure = true;

  @override
  void initState() {
    super.initState();

    // Auth state listener (auto-login if already signed in)
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final isCareGiver = doc.data()?['isCareGiver'] ?? false;
          if (mounted) {
            if (isCareGiver) {
              Navigator.pushReplacementNamed(context, '/caregiver');
            } else {
              Navigator.pushReplacementNamed(context, '/patient');
            }
          }
        }
      }
    });
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final isCareGiver = doc.data()?['isCareGiver'] ?? false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful")),
        );

        if (isCareGiver) {
          Navigator.pushReplacementNamed(context, '/caregiver');
        } else {
          Navigator.pushReplacementNamed(context, '/patient');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User role info not found.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-email':
          message = "Invalid email format.";
          break;
        default:
          message = "Login failed: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/guest');
          },
          child: Text("Continue As Guest"),
        ),
      ),
      appBar: AppBar(title: Text("Welcome To AlzCare"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
        child: ListView(
          children: [
            Text(
              "Today's Quote: ${quotes()}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: myTextFieldDesign(
                "Enter Email",
                "Email",
                Icons.email,
                Icons.check_circle,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: isObscure,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter Password",
                prefixIcon: Icon(Icons.password),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : loginUser,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Login"),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

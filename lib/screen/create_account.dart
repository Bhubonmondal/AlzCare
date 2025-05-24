import 'package:flutter/material.dart';
import '../controller/create_account_controller.dart';
import '../data/quotes.dart';
import '../data/textfield_design.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool ifChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/guest');
          },
          child: Text("Continue As Guest"),
        ),
      ),
      appBar: AppBar(title: Text("Create Account"), centerTitle: true),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50.0),
            child: ListView(
              children: [
                Image(width: 150, height: 150, image: AssetImage("assets/images/app_logo.jpeg")),
                SizedBox(height: 20),
                Text(
                  "Today's Quote: ${quotes()}",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
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
                  decoration: myTextFieldDesign(
                    "Enter Password",
                    "Password",
                    Icons.email,
                    Icons.check_circle,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  decoration: myTextFieldDesign(
                    "Confirm Password",
                    "Confirm Password",
                    Icons.email,
                    Icons.check_circle,
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: ifChecked,
                      onChanged: (value) {
                        setState(() {
                          ifChecked = value!;
                        });
                      },
                    ),
                    Text("Are you a Care Giver?"),
                  ],
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    createAccountController(
                      context,
                      emailController.text,
                      passwordController.text,
                      confirmPasswordController.text,
                      ifChecked,
                    );
                  },
                  child: Text("Sign Up"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?"),
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                    }, child: Text("Login")),
                  ],
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 100,  // Adjust this value to move the button upward or downward
          //   left: 0,
          //   right: 0,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
          //     child: ElevatedButton(
          //       onPressed: () {
          //         Navigator.pushReplacementNamed(context, '/guest');
          //       },
          //       child: Text("Continue As Guest"),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydrohealth/pages/dashboard_page.dart';
import 'package:hydrohealth/pages/forgot_password.dart';
import 'package:hydrohealth/pages/register_page.dart';
import 'package:hydrohealth/widgets/button_web.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Color myColor;
  late Size mediaSize;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberUser = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _getRememberMeStatus();
  }

  Future<void> _getRememberMeStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberUser = prefs.getBool('rememberUser') ?? false;
      if (rememberUser) {
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (rememberUser) {
        prefs.setString('email', emailController.text.trim());
        prefs.setString('password', passwordController.text.trim());
      } else {
        prefs.remove('email');
        prefs.remove('password');
      }
      prefs.setBool('rememberUser', rememberUser);
      prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } catch (error) {
      // ignore: avoid_print
      print("Error during login: $error");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } catch (error) {
      // ignore: avoid_print
      print("Error during Google sign-in: $error");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google sign-in failed: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: myColor,
        image: DecorationImage(
          image: const AssetImage("assets/images/login.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            myColor.withValues(alpha: 0.6),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(top: 80, child: _buildTop()),
            Positioned(bottom: 0, child: _buildBottom()),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: const SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "SMART GREEN GARDEN",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "HYDROHEALTH",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Welcome",
          style: TextStyle(
            color: Color.fromRGBO(153, 188, 133, 1),
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 50),
        _buildInputText(
          emailController,
          hintText: "Email Address",
          icon: Icons.email,
        ),
        const SizedBox(height: 20),
        _buildInputText(
          passwordController,
          hintText: "Password",
          isPassword: true,
          icon: Icons.lock,
        ),
        const SizedBox(height: 20),
        _buildRememberMe(),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ButtonWeb(
            onPressed: _loginUser,
            text: "Login",
          ),
        ),
        const SizedBox(height: 20),
        _buildGoogleSignInButton(),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ButtonWeb(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterPage(),
                ),
              );
            },
            text: "Register",
          ),
        ),
        const SizedBox(height: 20),
        _buildForgotPassword(),
      ],
    );
  }

  Widget _buildInputText(
    TextEditingController controller, {
    required String hintText,
    bool isPassword = false,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_passwordVisible : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: rememberUser,
          onChanged: (value) {
            setState(() {
              rememberUser = value!;
            });
          },
        ),
        const Text("Remember me"),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _loginWithGoogle,
        icon: const Icon(Icons.login),
        label: const Text("Sign in with Google"),
        style: ElevatedButton.styleFrom(
          foregroundColor:
              const Color.fromRGBO(153, 188, 133, 1), // Set text and icon color
          backgroundColor:
              const Color.fromRGBO(255, 255, 255, 1), // Set background color
          textStyle: const TextStyle(
            color: Color.fromRGBO(
                153, 188, 133, 1), // This is now redundant but can be kept
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPassword(),
            ),
          );
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(
            color:
                Color.fromRGBO(153, 188, 133, 1), // Change the text color here
          ),
        ),
      ),
    );
  }
}

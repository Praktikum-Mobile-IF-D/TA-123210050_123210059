import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizardingworld/dormitory/gryffindor.dart';
import 'package:wizardingworld/dormitory/hufflepuff.dart';
import 'package:wizardingworld/dormitory/ravenclaw.dart';
import 'package:wizardingworld/dormitory/slytherin.dart';
import 'package:wizardingworld/hive_database.dart';
import 'package:wizardingworld/registrasi.dart';
import 'package:wizardingworld/models/user_model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String email = prefs.getString('email') ?? '';
    if (isLoggedIn) {
      String dormitory = await _getUserDormitory(email);
      _navigateToDormitoryPage(dormitory, email);
    }
  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      User? user = await HiveDatabase.getUser(email);

      if (user != null && user.password == password) {
        await _saveLoginStatus(true, user.dormitory, email);
        _navigateToDormitoryPage(user.dormitory, user.email);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Email or password is incorrect!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Email or password can\'t be empty!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveLoginStatus(bool isLoggedIn, String dormitory, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setString('dormitory', dormitory);
    await prefs.setString('email', email);
  }

  Future<String> _getUserDormitory(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dormitory = prefs.getString('dormitory') ?? '';
    return dormitory;
  }

  void _navigateToDormitoryPage(String dormitory, String email) {
    switch (dormitory) {
      case 'Gryffindor':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GryffindorPage(email: email)),
        );
        break;
      case 'Hufflepuff':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HufflepuffPage(email: email)),
        );
        break;
      case 'Ravenclaw':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RavenclawPage(email: email)),
        );
        break;
      case 'Slytherin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SlytherinPage(email: email)),
        );
        break;
      default:
        _saveLoginStatus(false, '', '');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF10151B),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/sorting.png', height: 200.0),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white), // Text color inside the TextField
              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2F2E4D), // Background color
                  ),
                  onPressed: _login,
                  child: Text('LOGIN', style: TextStyle(color: Color(0xFFF6E1AB))),
                ),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationPage(),
                    ),
                  );
                },
                child: Text('Don\'t have an account? REGISTER HERE', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

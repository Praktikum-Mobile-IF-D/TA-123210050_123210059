import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizardingworld/camera.dart';
import 'package:wizardingworld/dormitory/gryffindor.dart';
import 'package:wizardingworld/dormitory/hufflepuff.dart';
import 'package:wizardingworld/dormitory/ravenclaw.dart';
import 'package:wizardingworld/dormitory/slytherin.dart';
import 'package:wizardingworld/info.dart';
import 'package:wizardingworld/models/user_model.dart';
import 'package:intl/intl.dart';

class DormitoryData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final String imagePath;

  DormitoryData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.imagePath,
  });
}

class ColorService {
  static final Map<String, DormitoryData> dormitoryData = {
    'Slytherin': DormitoryData(
      primaryColor: Color(0xFF1A472A),
      secondaryColor: Color(0xFF2A623D),
      textColor: Color(0xFFFFFFFF),
      imagePath: 'assets/images/slyprofpic.jpeg',
    ),
    'Ravenclaw': DormitoryData(
      primaryColor: Color(0xFF0F1D4A),
      secondaryColor: Color(0xFF213164),
      textColor: Color(0xFFFFFFFF),
      imagePath: 'assets/images/ravprofpic.jpeg',
    ),
    'Hufflepuff': DormitoryData(
      primaryColor: Color(0xFFEEB935),
      secondaryColor: Color(0xFFFFD25F),
      textColor: Color(0xFF372E29),
      imagePath: 'assets/images/hufprofpic.jpeg',
    ),
    'Gryffindor': DormitoryData(
      primaryColor: Color(0xFFAE0001),
      secondaryColor: Color(0xFFDC143C),
      textColor: Color(0xFFFFFFFF),
      imagePath: 'assets/images/gryprofpic.jpeg',
    ),
  };

  static DormitoryData getDormitoryData(String dormitory) {
    return dormitoryData[dormitory] ?? DormitoryData(
      primaryColor: Colors.white,
      secondaryColor: Colors.white,
      textColor: Colors.black,
      imagePath: 'assets/images/defaultprofpic.jpeg',
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String email;

  ProfilePage({required this.email});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences _prefs;
  String? _email;
  String? _name;
  String? _password;
  String? _dob;
  String? _dormitory;
  late DormitoryData _dormitoryData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserDorm();
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    final Box<User> userBox = await Hive.openBox<User>('users');
    final User? user = userBox.get(widget.email);

    if (user != null) {
      setState(() {
        _email = user.email;
        _name = user.name;
        _password = user.password;
        _dob = DateFormat('dd-MM-yyyy').format(user.birthDate);
        _dormitory = user.dormitory;
      });
    } else {
      print('User not found in Hive database');
    }
  }

  Future<void> _loadUserDorm() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _dormitory = _prefs.getString('dormitory') ?? '';
      _dormitoryData = ColorService.getDormitoryData(_dormitory!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: _dormitoryData.textColor)),
        backgroundColor: _dormitoryData.primaryColor,
        iconTheme: IconThemeData(color: _dormitoryData.textColor),
      ),
      body: Container(
        color: _dormitoryData.primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(_dormitoryData.imagePath),
              ),
              SizedBox(height: 20),
              Card(
                color: _dormitoryData.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $_name', style: TextStyle(color: _dormitoryData.textColor, fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Email: $_email', style: TextStyle(color: _dormitoryData.textColor, fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Password: $_password', style: TextStyle(color: _dormitoryData.textColor, fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Date of Birth: $_dob', style: TextStyle(color: _dormitoryData.textColor, fontSize: 18)),
                      SizedBox(height: 10),
                      Text('Dormitory: $_dormitory', style: TextStyle(color: _dormitoryData.textColor, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _dormitoryData.primaryColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, color: Colors.grey),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, color: Colors.grey),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.white),
            label: 'Profile',
          ),
        ],
        onTap: (int index) async {
          if (index == 0) {
            if (_dormitory == 'Slytherin') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SlytherinPage(email: widget.email),
                ),
              );
            } else if (_dormitory == "Ravenclaw") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RavenclawPage(email: widget.email),
                ),
              );
            } else if (_dormitory == "Hufflepuff") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HufflepuffPage(email: widget.email),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GryffindorPage(email: widget.email),
                ),
              );
            }
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraPage(email: widget.email),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Info(email: widget.email),
              ),
            );
          } else if (index == 3) {
            // ProfilePage
          }
        },
      ),
    );
  }
}

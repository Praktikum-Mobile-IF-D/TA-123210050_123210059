import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizardingworld/dormitory/gryffindor.dart';
import 'package:wizardingworld/dormitory/hufflepuff.dart';
import 'package:wizardingworld/dormitory/ravenclaw.dart';
import 'package:wizardingworld/dormitory/slytherin.dart';
import 'package:wizardingworld/info.dart';
import 'package:wizardingworld/profile.dart';

class ColorService {
  static const Map<String, List<Color>> dormitoryColors = {
    'Slytherin': [Color(0xFF1A472A), Color(0xFF2A623D), Color(0xFFFFFFFF)],
    'Ravenclaw': [Color(0xFF0F1D4A), Color(0xFF213164), Color(0xFFFFFFFF)],
    'Hufflepuff': [Color(0xFFEEB935), Color(0xFFFFD25F), Color(0xFF372E29)],
    'Gryffindor': [Color(0xFFAE0001), Color(0xFFDC143C), Color(0xFFFFFFFF)],
  };

  static List<Color> getDormitoryColors(String dormitory) {
    return dormitoryColors[dormitory] ?? [Colors.white, Colors.white, Colors.white];
  }
}

class CameraPage extends StatefulWidget {
  final String email;

  CameraPage({required this.email});
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late File _image = File('');
  late SharedPreferences _prefs;
  String? _dormitory;
  late List<Color> _dormitoryColors;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _dormitory = _prefs.getString('dormitory') ?? '';
      _dormitoryColors = ColorService.getDormitoryColors(_dormitory!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera', style: TextStyle(color: _dormitoryColors[2])),
        backgroundColor: _dormitoryColors[0],
        iconTheme: IconThemeData(color: _dormitoryColors[2]),
      ),
      body: Container(
        color: _dormitoryColors[1], // Warna latar belakang yang diambil dari warna dormitory
        child: Center(
          child: _image.path.isNotEmpty
              ? Image.file(_image)
              : Text('No image selected.', style: TextStyle(color: _dormitoryColors[2])),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Take a picture',
        child: Icon(Icons.camera_alt),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _dormitoryColors[0],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, color: Colors.grey),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.grey),
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
            //
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Info(email: widget.email),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(email: widget.email),
              ),
            );
          }
        },
      ),
    );
  }
}

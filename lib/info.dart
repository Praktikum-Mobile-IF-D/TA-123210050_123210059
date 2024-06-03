import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizardingworld/camera.dart';
import 'package:wizardingworld/dormitory/gryffindor.dart';
import 'package:wizardingworld/dormitory/hufflepuff.dart';
import 'package:wizardingworld/dormitory/ravenclaw.dart';
import 'package:wizardingworld/dormitory/slytherin.dart';
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

class Info extends StatefulWidget {
  final String email;

  Info({required this.email});
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  late SharedPreferences _prefs;
  String? _dormitory;
  late List<Color> _dormitoryColors;

  final List<Member> members = [
    Member(
      name: 'Maya Wulandari',
      imageUrl: 'assets/images/maya.jpeg',
      info: 'NIM 123210050',
    ),
    Member(
      name: 'Restiana Anggraeni',
      imageUrl: 'assets/images/restiana.jpg',
      info: 'NIM 123210059',
    ),
  ];

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
        title: Text('Our Developers', style: TextStyle(color: _dormitoryColors[2])),
        backgroundColor: _dormitoryColors[0],
        iconTheme: IconThemeData(color: _dormitoryColors[2]),
      ),
      body: Container(
        color: _dormitoryColors[0],
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (BuildContext context, int index) {
            return MemberCard(
              member: members[index],
              backgroundColor: _dormitoryColors[1],
            );
          },
        ),
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
            icon: Icon(Icons.camera_alt, color: Colors.grey),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, color: Colors.white),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraPage(email: widget.email),
              ),
            );
          } else if (index == 2) {
            //
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

class Member {
  final String name;
  final String imageUrl;
  final String info;

  Member({
    required this.name,
    required this.imageUrl,
    required this.info,
  });
}

class MemberCard extends StatelessWidget {
  final Member member;
  final Color backgroundColor;

  const MemberCard({
    required this.member,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(20),
      child: Container(
        color: backgroundColor, // Set background color here
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                member.imageUrl,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  member.info,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

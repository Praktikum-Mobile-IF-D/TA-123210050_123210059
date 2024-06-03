import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class StaffPage extends StatefulWidget {
  @override
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  List<dynamic> staffList = [];
  late List<Color> _dormitoryColors;
  late SharedPreferences _prefs;
  String? _dormitory;

  @override
  void initState() {
    super.initState();
    fetchData();
    _loadUserData();
  }

  void fetchData() async {
    final response = await http.get(Uri.parse('https://hp-api.onrender.com/api/characters/staff'));
    if (response.statusCode == 200) {
      setState(() {
        staffList = json.decode(response.body);
      });
    } else {
      print('Gagal memuat data: ${response.statusCode}');
    }
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
        title: Text('Staff', style: TextStyle(color: _dormitoryColors[2])),
        backgroundColor: _dormitoryColors[0],
          iconTheme: IconThemeData(color: _dormitoryColors[2])
      ),
      body: ListView.builder(
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          var staffItem = staffList[index]; // Ubah variabel staff menjadi staffItem
          return ListTile(
            tileColor: _dormitoryColors[1],
            leading: CircleAvatar(
              backgroundImage: NetworkImage(staffItem['image']), // Gunakan staffItem
            ),
            title: Text(staffItem['name'], style: TextStyle(color: _dormitoryColors[2])), // Gunakan staffItem
            subtitle: Text(staffItem['house'], style: TextStyle(color: _dormitoryColors[2])), // Gunakan staffItem
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StaffDetailPage(staff: staffItem), // Gunakan staffItem
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class StaffDetailPage extends StatefulWidget {
  final Map<String, dynamic> staff;

  StaffDetailPage({required this.staff});

  @override
  _StaffDetailPageState createState() => _StaffDetailPageState();
}

class _StaffDetailPageState extends State<StaffDetailPage> {
  late List<Color> _dormitoryColors = [Colors.white, Colors.white, Colors.white];
  late SharedPreferences _prefs;
  String? _dormitory;

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
        title: Text('Staff Detail', style: TextStyle(color: _dormitoryColors[2])),
        backgroundColor: _dormitoryColors[0],
          iconTheme: IconThemeData(color: _dormitoryColors[2])
      ),
      body: Container(
        color: _dormitoryColors[0],
        padding: EdgeInsets.all(16.0),
        child: Card(
          color: _dormitoryColors[1],
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(widget.staff['image']),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: Text(
                    widget.staff['name'],
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _dormitoryColors[2],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text('House \t: ${widget.staff['house']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Species \t: ${widget.staff['species']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Gender \t: ${widget.staff['gender']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Year of Birth \t: ${widget.staff['yearOfBirth']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Wizard \t: ${widget.staff['wizard']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Actor \t: ${widget.staff['actor']}', style: TextStyle(color: _dormitoryColors[2])),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

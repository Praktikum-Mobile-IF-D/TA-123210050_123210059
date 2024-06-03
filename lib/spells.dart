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

class SpellPage extends StatefulWidget {
  @override
  _SpellPageState createState() => _SpellPageState();
}

class _SpellPageState extends State<SpellPage> {
  List<dynamic> spellList = [];
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
    final response = await http.get(Uri.parse('https://hp-api.onrender.com/api/spells'));
    if (response.statusCode == 200) {
      setState(() {
        spellList = json.decode(response.body);
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
        title: Text('Spells', style: TextStyle(color: _dormitoryColors[2])),
        backgroundColor: _dormitoryColors[0],
          iconTheme: IconThemeData(color: _dormitoryColors[2])
      ),
      body: ListView.builder(
        itemCount: spellList.length,
        itemBuilder: (context, index) {
          var spells = spellList[index];
          return ListTile(
            tileColor: _dormitoryColors[1],
            title: Text(spells['name'], style: TextStyle(color:_dormitoryColors[2])),
            subtitle: Text('${spells['description']}', style: TextStyle(color:_dormitoryColors[2])),
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => BreweryDetailPage(brewery: brewery),
            //     ),
            //   );
            // },
          );
        },
      ),
    );
  }
}


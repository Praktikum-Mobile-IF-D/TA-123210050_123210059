import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

class PotionPage extends StatefulWidget {
  @override
  _PotionPageState createState() => _PotionPageState();
}

class _PotionPageState extends State<PotionPage> {
  List<dynamic> potionList = [];
  List<dynamic> favoriteList = [];
  late List<Color> _dormitoryColors;
  late SharedPreferences _prefs;
  String? _dormitory;
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    loadFavorites();
    _loadUserData();
    _searchController.addListener(_searchPotions);
  }

  void fetchData() async {
    final response = await http.get(Uri.parse('https://api.potterdb.com/v1/potions'));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> potions = responseData['data'];
      setState(() {
        potionList = potions; // Mengambil list potion dari respons API
      });
    } else {
      print('Gagal memuat data: ${response.statusCode}');
    }
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites');
    if (favorites != null) {
      setState(() {
        favoriteList = favorites.map((e) => json.decode(e)).toList();
      });
    }
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _dormitory = _prefs.getString('dormitory') ?? '';
      _dormitoryColors = ColorService.getDormitoryColors(_dormitory!);
    });
  }

  void toggleFavorite(dynamic potion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (favoriteList.contains(potion)) {
      favoriteList.remove(potion);
    } else {
      favoriteList.add(potion);
    }
    List<String> favorites = favoriteList.map((e) => json.encode(e)).toList();
    await prefs.setStringList('favorites', favorites);
    setState(() {});
  }

  bool isFavorite(dynamic potion) {
    return favoriteList.any((element) => element['id'] == potion['id']);
  }

  void _searchPotions() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      potionList = potionList.where((potion) {
        var name = potion['attributes']['name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search potions...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
          autofocus: true,
        )
            : Text('Potions', style: TextStyle(color: _dormitoryColors[2])),
        backgroundColor: _dormitoryColors[0],
        iconTheme: IconThemeData(color: _dormitoryColors[2]),
        actions: _isSearching
            ? [
          IconButton(
            icon: Icon(Icons.clear, color: Colors.white),
            onPressed: _stopSearch,
          ),
        ]
            : [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _startSearch,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: potionList.length,
        itemBuilder: (context, index) {
          var potionItem = potionList[index];
          var imageUrl = potionItem['attributes']?['image']; // Pemeriksaan null-aware
          return ListTile(
            tileColor: _dormitoryColors[1],
            leading: CircleAvatar(
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null, // Operator ternary
            ),
            title: Text(potionItem['attributes']?['name'] ?? '', style: TextStyle(color: _dormitoryColors[2])), // Pemeriksaan null-aware dan operator ternary
            trailing: IconButton(
              icon: Icon(
                isFavorite(potionItem) != null ?
                isFavorite(potionItem) ? Icons.favorite : Icons.favorite_border
                    : Icons.favorite_border, // Menggunakan operator ternary untuk mengecek apakah isFavorite(potionItem) adalah null
                color: isFavorite(potionItem) != null ?
                isFavorite(potionItem) ? Colors.red : null
                    : _dormitoryColors[2], // Jika null, atur warna border menjadi putih
              ),
              onPressed: () {
                toggleFavorite(potionItem);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PotionDetailPage(potion: potionItem),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PotionDetailPage extends StatefulWidget {
  final Map<String, dynamic> potion;

  PotionDetailPage({required this.potion});

  @override
  _PotionDetailPageState createState() => _PotionDetailPageState();
}

class _PotionDetailPageState extends State<PotionDetailPage> {
  late List<Color> _dormitoryColors;
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
          title: Text('Potion Detail', style: TextStyle(color: _dormitoryColors[2])),
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
                    backgroundImage: NetworkImage(widget.potion['attributes']['image']),
                  ),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: Text(
                    widget.potion['attributes']['name'],
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _dormitoryColors[2],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Text('Slug \t: ${widget.potion['attributes']['slug']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Characteristic \t: ${widget.potion['attributes']['characteristics']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Difficulty \t: ${widget.potion['attributes']['difficulty']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Effect \t: ${widget.potion['attributes']['effect']}', style: TextStyle(color: _dormitoryColors[2])),
                Text('Ingredients \t: ${widget.potion['attributes']['ingredients']}', style: TextStyle(color: _dormitoryColors[2])),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _launchURL(widget.potion['attributes']['wiki']);
                    },
                    child: Text(
                      'More Info',
                      style: TextStyle(color: _dormitoryColors[2]),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _dormitoryColors[0],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if(!await launchUrl(_url)){
      throw 'Could not launch $_url';
    }
  }
}
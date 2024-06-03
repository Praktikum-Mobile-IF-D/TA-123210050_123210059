import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wizardingworld/potions.dart';



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

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Color> _dormitoryColors;
  late SharedPreferences _prefs;
  String? _dormitory;

  Future<List<dynamic>> _fetchFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites');
    if (favorites != null) {
      return favorites.map((e) => json.decode(e)).toList();
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _loadUserData();
  }


  void removeFavorite(dynamic potion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> favoriteList = await _fetchFavorites();

    setState(() {
      favoriteList.removeWhere((element) => element['id'] == potion['id']);
    });
    List<String> favorites = favoriteList.map((e) => json.encode(e)).toList();
    await prefs.setStringList('favorites', favorites);
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
        title: Text('Favorite Potions', style: TextStyle(color: _dormitoryColors[2]),),
        backgroundColor: _dormitoryColors[0],
        iconTheme:  IconThemeData(color: _dormitoryColors[2]),
      ),
      body: Container(
        color: _dormitoryColors[0],
        child: FutureBuilder<List<dynamic>>(
          future: _fetchFavorites(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading favorites'));
            } else {
              List<dynamic> favoriteList = snapshot.data ?? [];
              return favoriteList.isEmpty
                  ? Center(child: Text('No favorites added.'))
                  : ListView.builder(
                itemCount: favoriteList.length,
                itemBuilder: (context, index) {
                  var potionItem = favoriteList[index];
                  var imageUrl = potionItem['attributes']?['image'];
                  return ListTile(
                    tileColor: _dormitoryColors[2],
                    leading: CircleAvatar(
                      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    ),
                    title: Text(potionItem['attributes']?['name'] ?? '', style: TextStyle(color: _dormitoryColors[2])),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        removeFavorite(potionItem);
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
              );
            }
          },
        ),
      ),


    );
  }
}

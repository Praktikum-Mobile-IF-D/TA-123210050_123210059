import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wizardingworld/camera.dart';
import 'package:wizardingworld/favorite.dart';
import 'package:wizardingworld/info.dart';
import 'dart:convert';
import 'package:wizardingworld/login.dart';
import 'package:wizardingworld/potions.dart';
import 'package:wizardingworld/profile.dart';
import 'package:wizardingworld/spells.dart';
import 'package:wizardingworld/staff.dart';

// 'Ravenclaw': [Color(0xFF0F1D4A), Color(0xFF213164), Color(0xFFFFFFFF)],

class RavenclawPage extends StatefulWidget {
  final String email;

  RavenclawPage({required this.email});
  @override
  _RavenclawPageState createState() => _RavenclawPageState();
}

class _RavenclawPageState extends State<RavenclawPage> {
  List<Character> characters = [];
  List<dynamic> favoriteList = [];
  bool isLoading = true;
  final int maxCharacters = 2;

  @override
  void initState() {
    super.initState();
    fetchCharacters();
    loadFavorites();
  }

  Future<void> fetchCharacters() async {
    final response = await http.get(Uri.parse('https://hp-api.onrender.com/api/characters/house/ravenclaw'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        characters = data.map((item) => Character.fromJson(item)).take(maxCharacters).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load characters');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome to',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              'Ravenclaw',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Color(0xFF0F1D4A),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF0F1D4A),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(height: 16.0),
            Text(
              'Popular Characters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: characters.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Card(
                      elevation: 2.0,
                      color: Color(0xFF213164),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 50.0,
                        height: 100.0,
                        child: Image.asset(
                          'assets/images/Ravenclaw.png',
                        ),
                      ),
                    );
                  } else {
                    final characterIndex = index - 1;
                    return GestureDetector(
                      child: Card(
                        elevation: 2.0,
                        color: Color(0xFF213164),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 150.0,
                          height: 220.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100.0,
                                  height: 120.0,
                                  child: Image.network(
                                    characters[characterIndex].image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  characters[characterIndex].name,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildMenuItem('assets/images/staff.png', 'Staff', context, StaffPage()),
                  _buildMenuItem('assets/images/potion.png', 'Potions', context, PotionPage()),
                  _buildMenuItem('assets/images/spell.png', 'Spells', context, SpellPage()),
                  _buildMenuItem('assets/images/favorite.png', 'Favorite', context, FavoritesPage()),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF0F1D4A),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, color: Colors.grey),
            label: 'camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, color: Colors.grey),
            label: 'info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.grey),
            label: 'profile',
          ),
        ],
        onTap: (int index) async {
          if (index == 0) {
            //
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

  Widget _buildMenuItem(String imagePath, String title, BuildContext context, Widget page) {
    return Container(
      color: Color(0xFF213164),
      child: ListTile(
        title: Column(
          children: [
            Image.asset(
              imagePath,
              width: 100.0,
              height: 100.0,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

}

class Character {
  final String id;
  final String name;
  final String image;

  Character({required this.id, required this.name, required this.image});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}


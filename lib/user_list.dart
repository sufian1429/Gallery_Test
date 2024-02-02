import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'album_list.dart';

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<dynamic> userList = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (response.statusCode == 200) {
        setState(() {
          userList = json.decode(response.body);
        });
      } else {
        print('Failed to load users - ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<int> _fetchAlbumCount(int userId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/albums?userId=$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> albums = json.decode(response.body);
        return albums.length;
      } else {
        print('Failed to load albums - ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching albums: $error');
    }
    return 0;
  }

  Future<int> _fetchPhotoCount(int albumId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/photos?albumId=$albumId'));
      if (response.statusCode == 200) {
        final List<dynamic> photos = json.decode(response.body);
        return photos.length;
      } else {
        print('Failed to load photos - ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching photos: $error');
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                'https://source.unsplash.com/200x200/?',
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
            ),
            title: Text(user['name']),
            subtitle: FutureBuilder<int>(
              future: _fetchAlbumCount(user['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final albumCount = snapshot.data ?? 0;
                  return FutureBuilder<int>(
                    future: _fetchPhotoCount(albumCount > 0 ? albumCount : 0),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final photoCount = snapshot.data ?? 0;
                        return Text('$albumCount albums, $photoCount photos');
                      }
                    },
                  );
                }
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AlbumList(userId: user['id'], userName: user['name']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gallery_test2/album_photos.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlbumList extends StatefulWidget {
  final int userId;
  final String userName;

  const AlbumList({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  List<dynamic> albumList = [];

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
  }

  Future<void> _fetchAlbums() async {
    try {
      final response = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/albums?userId=${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          albumList = json.decode(response.body);
        });
      } else {
        print('Failed to load albums - ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching albums: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: 20,
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        'https://source.unsplash.com/200x200/?',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                    title: Text(
                      '${widget.userName} ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2),
                        Text(
                          'User ID: ${widget.userId} - Album ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: albumList.length,
                  itemBuilder: (context, index) {
                    final album = albumList[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoGallery(
                                albumId: album['id'],
                                albumTitle: album['title'],
                              ),
                            ),
                          );
                        },
                        child: GridTile(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.network(
                              'https://source.unsplash.com/200x200/?${album['title']}',
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            ),
                          ),
                          header: GridTileBar(
                            title: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.lightBlueAccent),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                album['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

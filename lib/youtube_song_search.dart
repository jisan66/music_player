import 'package:flutter/material.dart';
import 'package:music_player/Player_ui.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeSearchPage extends StatefulWidget {
  @override
  _YouTubeSearchPageState createState() => _YouTubeSearchPageState();
}

class _YouTubeSearchPageState extends State<YouTubeSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Video> _videos = [];
  bool _isLoading = false;
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  Future<void> _searchYouTube(String value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // final searchQuery = _searchController.text;
      final searchResults = await _youtubeExplode.search.getVideos(value);

      setState(() {
        _videos = searchResults.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeExplode.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('YouTube Search...', style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (value){
                _searchYouTube(value.toString());
              },
              controller: _searchController,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey
                  )
                ),
                fillColor: Colors.grey.withOpacity(.1),
                filled: true,
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey
                  )
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.red
                  )
                ),
                labelText: 'Search song...',
                suffixIcon: Card(
                  elevation: 4,
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    // onPressed: _searchYouTube,
                    onPressed: (){},
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty ? const Center(child: Text("No Song Found!"),) : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    leading: SizedBox(
                      width: 50, // Set the width to match the expected image size
                      height: 50, // Set the height to match the expected image size
                      child: Image.network(
                        video.thumbnails.standardResUrl,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child; // Image is fully loaded
                          } else {
                            return const Icon(Icons.image_not_supported, size: 30, color: Colors.grey); // Icon while loading
                          }
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const Icon(Icons.broken_image_outlined, size: 30, color: Colors.red); // Icon when error loading image
                        },
                      ),
                    ),
                    title: Text(video.title),
                    subtitle: Text(video.author),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => MyMusicPlayer(video: video))); // Navigate with video
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

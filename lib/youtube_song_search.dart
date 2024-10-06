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

  Future<void> _searchYouTube() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final searchQuery = _searchController.text;
      final searchResults = await _youtubeExplode.search.getVideos(searchQuery);

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
        title: Text('YouTube Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search YouTube',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchYouTube,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return ListTile(
                  leading: Image.network(video.thumbnails.standardResUrl),
                  title: Text(video.title),
                  subtitle: Text(video.author),
                  onTap: () {
                    // Pass the video URL back or do something with it
                    String videoUrl = video.url;
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>MyMusicPlayer(video : video))); // Pass back the video URL
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

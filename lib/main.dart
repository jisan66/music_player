import 'package:flutter/material.dart';
import 'package:music_player/youtube_song_search.dart';
import 'Player_ui.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YouTubeSearchPage(),
      debugShowCheckedModeBanner: false,
      title: "Music Player",
    );
  }
}

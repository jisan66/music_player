import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MyMusicPlayer extends StatefulWidget {
  final Video video;
  const MyMusicPlayer({super.key, required this.video});

  @override
  State<MyMusicPlayer> createState() => _MyMusicPlayerState();
}

class _MyMusicPlayerState extends State<MyMusicPlayer> {
  final AudioPlayer player = AudioPlayer();
  final YoutubeExplode youtube = YoutubeExplode();
  String youtubeUrl = ""; // YouTube URL
  String thumbnailImgUrl =
      "https://img.freepik.com/free-vector/musical-pentagram-sound-waves-notes-background_1017-33911.jpg"; // Thumbnail
  bool loaded = false;
  bool playing = false;

  // Extract and play audio
  Future<void> _extractAudioAndPlay() async {
    try {
      var videoId = VideoId(youtubeUrl);
      var manifest = await youtube.videos.streamsClient.getManifest(videoId);
      var audioStreamInfo = manifest.audioOnly.withHighestBitrate();

      print("Audio Stream URL: ${audioStreamInfo.url}");  // Debug print

      await player.setUrl(audioStreamInfo.url.toString()); // Set audio stream URL
      setState(() {
        loaded = true;
      });
      playMusic();
    } catch (e) {
      print("Error extracting audio: $e");
    }
  }

  @override
  void playMusic() async {
    setState(() {
      playing = true;
    });
    await player.play();
  }
  @override
  void pauseMusic() async {
    setState(() {
      playing = false;
    });
    await player.pause();
  }

  @override
  void initState() {
    super.initState();
    youtubeUrl = widget.video.url;
    _extractAudioAndPlay(); // Extract and play audio from YouTube
  }

  @override
  void dispose() {
    player.dispose();
    youtube.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                thumbnailImgUrl,
                height: size.height,
                width: size.width,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Musix Player",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54)),
                      Text("Song Name - YouTube Audio",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54)),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                const SizedBox(height: 350, width: 350),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, snapshot) {
                        final Duration position =
                            snapshot.data ?? const Duration();
                        final Duration buffered =
                            player.bufferedPosition ?? const Duration();
                        final Duration total =
                            player.duration ?? const Duration();
                        return ProgressBar(
                          progress: position,
                          buffered: buffered,
                          total: total,
                          progressBarColor: Colors.red,
                          baseBarColor: Colors.grey[200],
                          bufferedBarColor: Colors.grey[350],
                          thumbColor: Colors.red,
                          timeLabelTextStyle:
                          const TextStyle(fontSize: 14, color: Colors.black),
                          onSeek: (duration) async {
                            await player.seek(duration);
                          },
                        );
                      }),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final currentPosition = player.position;
                        if (currentPosition.inSeconds >= 10) {
                          await player.seek(Duration(
                              seconds: currentPosition.inSeconds - 10));
                        } else {
                          await player.seek(const Duration(seconds: 0));
                        }
                      },
                      icon: const Icon(Icons.fast_rewind_rounded),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (playing) {
                            pauseMusic();
                          } else {
                            playMusic();
                          }
                        },
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final currentPosition = player.position;
                        if (currentPosition.inSeconds + 10 <=
                            (player.duration?.inSeconds ?? 0)) {
                          await player.seek(Duration(
                              seconds: currentPosition.inSeconds + 10));
                        } else {
                          await player.seek(player.duration ??
                              const Duration(seconds: 0));
                        }
                      },
                      icon: const Icon(Icons.fast_forward_rounded),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

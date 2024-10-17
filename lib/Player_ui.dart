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
  String songName = "";
  bool isLoading = false;

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

  void playMusic() async {
    setState(() {
      playing = true;
    });
    await player.play();
  }
  void pauseMusic() async {
    setState(() {
      playing = false;
    });
    await player.pause();
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    youtubeUrl = widget.video.url;
    songName = widget.video.title;
    thumbnailImgUrl = widget.video.thumbnails.standardResUrl;
    _extractAudioAndPlay();
    isLoading = false;
    setState(() {});// Extract and play audio from YouTube
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
          Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment(1, 0.8),
                  colors: <Color>[
                    Color(0xff1f005c),
                    Color(0xff5b0060),
                    Color(0xff870160),
                    Color(0xffac255e),
                    Color(0xffca485c),
                    Color(0xffe16b5c),
                    Color(0xfff39060),
                    Color(0xffffb56b),
                  ], // Gradient from https://learnui.design/tools/gradient-generator.html
                  tileMode: TileMode.mirror,
                ),
              ),
              child: Stack(
                children: [
                  isLoading ? const Center(child: CircularProgressIndicator(),) : Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Image.network(
                            thumbnailImgUrl,
                            height: size.height,
                            width: size.width,
                            fit: BoxFit.contain,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: const Alignment(0.8, 1),
                                colors: <Color>[
                                  const Color(0xffffffff).withOpacity(0.1),
                                  const Color(0xff000000).withOpacity(.5),
                                  const Color(0xffffffff).withOpacity(0.1),
                                ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                tileMode: TileMode.mirror,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ),

                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Card(
                        elevation: 4,
                        color: Color(0xffca485c),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Musix Player",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 4,
                          color: const Color(0xffca485c),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Song Name - $songName",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
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

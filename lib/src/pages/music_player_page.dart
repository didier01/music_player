import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:music_player/src/helpers/helpers.dart';
import 'package:music_player/src/models/audio_player_model.dart';
import 'package:music_player/src/widgets/custom_appBar.dart';
import 'package:provider/provider.dart';

class MusicPlayerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Background(),
          Column(
            children: [
              CustomAppBar(),
              ImageDurationDisc(),
              PlayTitle(),
              Lyrics(),
            ],
          ),
        ],
      ),
    );
  }
}

class Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: screenSize.height * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.center,
            colors: [
              Color(0xff33333e),
              Color(0xff201e28),
            ]),
      ),
    );
  }
}

class ImageDurationDisc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      margin: EdgeInsets.only(top: 80),
      child: Row(
        children: [
          ImageDisc(),
          SizedBox(width: 40),
          ProgresBar(),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}

class ProgresBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final styleNumber = TextStyle(color: Colors.white.withOpacity(0.5));
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);
    final percent = audioPlayerModel.percent;

    return Container(
      child: Column(
        children: [
          Text('${audioPlayerModel.songTotalDuration}', style: styleNumber),
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                  width: 3, height: 220, color: Colors.white.withOpacity(0.2)),
              Positioned(
                bottom: 0,
                child: Container(
                    width: 3,
                    height: 220 * percent,
                    color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('${audioPlayerModel.currentSecond}', style: styleNumber),
        ],
      ),
    );
  }
}

class ImageDisc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);

    return Container(
      padding: EdgeInsets.all(20),
      width: 250,
      height: 250,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SpinPerfect(
                  duration: Duration(seconds: 10),
                  infinite: true,
                  manualTrigger: true,
                  controller: (animationCtrl) =>
                      audioPlayerModel.controller = animationCtrl,
                  child: Image(image: AssetImage('assets/onerepublic.jpg'))),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Color(0xff1e1c24),
                  borderRadius: BorderRadius.circular(200),
                ),
              )
            ],
          )),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [
            Color(0xff484759),
            Color(0xff1e1c24),
          ],
        ),
      ),
    );
  }
}

class PlayTitle extends StatefulWidget {
  @override
  _PlayTitleState createState() => _PlayTitleState();
}

class _PlayTitleState extends State<PlayTitle>
    with SingleTickerProviderStateMixin {
  bool isplaying = false;
  bool firstTime = true;
  late AnimationController playAnimation;

  final assetAudioPlayer = new AssetsAudioPlayer();

  @override
  void initState() {
    playAnimation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    super.initState();
  }

  @override
  void dispose() {
    this.playAnimation.dispose();
    super.dispose();
  }

  void open() {
    final audioPlayerModel =
        Provider.of<AudioPlayerModel>(context, listen: false);
    assetAudioPlayer.open(Audio('assets/Rescue-Me.mp3'));

    assetAudioPlayer.currentPosition.listen((duration) {
      audioPlayerModel.current = duration;
    });

    assetAudioPlayer.current.listen((playing) {
      audioPlayerModel.songDuration = playing!.audio.duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      margin: EdgeInsets.only(top: 50),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                'Recue me',
                style: TextStyle(
                    fontSize: 30, color: Colors.white.withOpacity(0.8)),
              ),
              Text(
                '-One Republic-',
                style: TextStyle(
                    fontSize: 15, color: Colors.white.withOpacity(0.5)),
              )
            ],
          ),
          Spacer(),
          FloatingActionButton(
            highlightElevation: 0,
            elevation: 0,
            backgroundColor: Color(0xff4AA1BF),
            child: AnimatedIcon(
              progress: playAnimation,
              icon: AnimatedIcons.play_pause,
            ),
            onPressed: () {
              final audioPlayerModel =
                  Provider.of<AudioPlayerModel>(context, listen: false);
              if (this.isplaying ) {
                playAnimation.reverse();
                this.isplaying = false;
                audioPlayerModel.controller.stop();
              } else {
                playAnimation.forward();
                this.isplaying = true;
                audioPlayerModel.controller.repeat();
              }
              if (firstTime) {
                this.open();
                firstTime = false;
              }else {
                assetAudioPlayer.playOrPause();
              }
            },
          ),
          FloatingActionButton(onPressed: (){
            assetAudioPlayer.stop();
          })
        ],
      ),
    );
  }
}

class Lyrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lyrics = getLyrics();
    return Expanded(
      child: Container(
        // height: 300,
        child: ListWheelScrollView(
          itemExtent: 42,
          diameterRatio: 1.5,
          useMagnifier: true,
          magnification: 1.5,
          physics: BouncingScrollPhysics(),
          children: lyrics
              .map((row) => Text(
                    row,
                    style: TextStyle(
                        fontSize: 20, color: Colors.white.withOpacity(0.8)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

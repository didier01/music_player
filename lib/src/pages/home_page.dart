import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:file_manager/file_manager.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FileManagerController controller = FileManagerController();

  String _platformVersion = 'Unknown';
  bool isPlaying = false;
  Duration _duration = new Duration(milliseconds: 0);
  Duration _position = new Duration(milliseconds: 0);
  double _slider = 0;
  double _sliderVolume = 0;
  String _error = '';
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;
  var style = TextStyle(color: Colors.white38);

  List<FileSystemEntity> entitie = [];
  List music = [];
  final List list = [
    {
      "title": "network",
      "desc": "network resouce playback",
      "url": "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a",
      "coverUrl": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"
    }
  ];

  @override
  void initState() {
    super.initState();
    checkPermissionStorage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    AudioManager.instance.release();
    super.dispose();
  }

  checkPermissionStorage() async {
    var externalStorageStatus = await Permission.manageExternalStorage.status;
    var storageStatus = await Permission.storage.status;

    if (!storageStatus.isGranted) {
      await Permission.storage.request();
      await getData();
    }
    if (!externalStorageStatus.isGranted) {
      await Permission.manageExternalStorage.request();
      entitie = Directory('/storage/38C1-1B01/music').listSync();
      await getData();
    }
    if (storageStatus.isGranted) {
      await getData();
    }
  }

  getData() async {
    entitie = Directory('/storage/38C1-1B01/music').listSync();
    entitie.forEach((item) {
      var name = FileManager.basename(item);
      var path = item.uri.toString();
      music.add({
        'url': path,
        'title': name,
        'desc': 'You are what you listen',
        'coverUrl': 'assets/black-head.jpg',
      });
    });
    setState(() {});
    await initPlatformState();
    await setupAudio();
  }

  setupAudio() async {
    // var lst = Directory('/storage/38C1-1B01/music');
    // final List<FileSystemEntity> entitie = lst.listSync();

    List<AudioInfo> _list = [];

    music.forEach((item) {
      var name = item['title'];
      var path = item['url'];
      var desc = item['desc'];
      var cover = item['coverUrl'];

      _list.add(AudioInfo(path, title: name, desc: desc, coverUrl: cover));
    });

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.start:
          // print(
          //     "start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          setState(() {});
          break;
        case AudioManagerEvents.ready:
          // print("ready to play");
          _error = 'null';
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          setState(() {});
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          // print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          // print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = AudioManager.instance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          _error = args;
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  loadFile() async {
    // read bundle file to local path
    final audioFile = await rootBundle.load("assets/Rescue-Me.mp3");
    final audio = audioFile.buffer.asUint8List();

    final appDocDir = await getApplicationDocumentsDirectory();

    final file = File("${appDocDir.path}/Rescue-Me.mp3");
    file.writeAsBytesSync(audio);

    AudioInfo info = AudioInfo("file://${file.path}",
        title: "file", desc: "local file", coverUrl: "assets/onerepublic.jpg");

    // getData();
    list.add(info.toJson());
    AudioManager.instance.audioList.add(info);
    setState(() {});
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Widget bottomPanel(current) {
    Color _color = Colors.white38;
    double _iconSize = 30.0;
    return Container(
      child: Column(children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 5),
          child: songProgress(context),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  iconSize: _iconSize,
                  icon: getPlayModeIcon(playMode),
                  onPressed: () {
                    playMode = AudioManager.instance.nextMode();
                    setState(() {});
                  }),
              IconButton(
                  iconSize: _iconSize,
                  icon: Icon(
                    Icons.skip_previous,
                    color: _color,
                  ),
                  onPressed: () => AudioManager.instance.previous()),
              IconButton(
                onPressed: () async {
                  bool playing = await AudioManager.instance.playOrPause();
                },
                padding: const EdgeInsets.all(0.0),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 40.0,
                  color: _color,
                ),
              ),
              IconButton(
                  iconSize: _iconSize,
                  icon: Icon(
                    Icons.skip_next,
                    color: _color,
                  ),
                  onPressed: () => AudioManager.instance.next()),
              IconButton(
                  iconSize: _iconSize,
                  icon: Icon(
                    Icons.stop_rounded,
                    color: _color,
                  ),
                  onPressed: () => AudioManager.instance.stop()),
            ],
          ),
        ),
      ]),
    );
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    Color _color = Colors.white38;

    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: _color,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: _color,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: _color,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    Color _color = Colors.white38;

    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.black38,
                  overlayColor: Colors.black38,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.black38,
                  inactiveTrackColor: _color,
                ),
                child: Slider(
                  value: _slider,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                              (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  double _height = 110;
  bool open = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var currentItem;
    return Scaffold(
      backgroundColor: Color(0xff18191d),
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Center(child: Text('Music App')),
      //   // leading: IconButton(
      //   //   onPressed: () async {
      //   //     await controller.goToParentDirectory();
      //   //   },
      //   //   icon: Icon(Icons.arrow_back_ios_sharp),
      //   // ),
      //   // actions: [
      //   //   IconButton(
      //   //     onPressed: () => selectStorage(context, controller),
      //   //     icon: Icon(Icons.sd_storage_rounded),
      //   //   ),
      //   // ],
      // ),
      // body: SongList(controller),
      body: Stack(
        children: [
          Background(),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    'Songs',
                    style: TextStyle(color: Colors.white60, fontSize: 28.0),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: music.length,
                      itemBuilder: (BuildContext context, int index) {
                        var name = music[index]['title'];
                        return ListTile(
                          title: Text(name),
                          leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image(
                                    image: AssetImage('assets/head.jpg'),
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ],
                              )),
                          onTap: () => {
                            currentItem = music[index],
                            AudioManager.instance.play(index: index)
                          },
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff333a40),
          mini: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff18191d),
                    Color(0xff333a40),
                  ]),
            ),
            child: Icon(
              open
                  ? Icons.arrow_drop_down_rounded
                  : Icons.arrow_drop_up_rounded,
              color: Colors.white38,
              size: 40.0,
            ),
          ),
          onPressed: () {
            setState(() {
              if (open) {
                _height = 110;
                open = false;
              } else {
                _height = screenSize.height * 0.91;
                Future.delayed(const Duration(milliseconds: 100), () {
                  open = true;
                });
              }
            });
          }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: CircularNotchedRectangle(),
        color: Color(0xff18191d),
        child: AnimatedContainer(
          height: _height,
          duration: Duration(seconds: 10),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff333a40),
                  Color(0xff18191d),
                ]),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              open ? ImageSong() : Container(),
              Positioned(
                child: bottomPanel(currentItem),
              ),
            ],
          ),
        ),
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
      height: screenSize.height * 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Color(0xff414345),
              // Color(0xff232526),
              Color(0xff333a40),
              Color(0xff18191d),
            ]),
      ),
    );
  }
}

class ImageSong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: 320,
      height: 320,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image(
                // image: AssetImage('assets/face2.jpg'),
                image: AssetImage('assets/headphone.jpg'),
                fit: BoxFit.cover,
                width: 300,
                height: 300,
                filterQuality: FilterQuality.high,
              ),
            ],
          )),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: [
            // Color(0xff484759),
            // Color(0xff1e1c24),
            Color(0xff18191d),
            Color(0xff333a40),
          ],
        ),
      ),
    );
  }
}

// class SongList extends StatelessWidget {
//   final controller;
//   const SongList(this.controller);

//   @override
//   Widget build(BuildContext context) {
//     var lst = Directory('/storage/38C1-1B01/music');
//     final List<FileSystemEntity> entitie = lst.listSync();

//     return FileManager(
//       controller: controller,
//       builder: (context, snapshot) {
//         // final List<FileSystemEntity> entities = snapshot;
//         // final List<FileSystemEntity> entitie = lst.listSync();
//         return ListView.builder(
//           itemCount: entitie.length,
//           itemBuilder: (context, index) {
//             FileSystemEntity entity = entitie[index];
//             return Card(
//               child: ListTile(
//                 leading: FileManager.isFile(entity)
//                     ? Icon(Icons.feed_outlined)
//                     : Icon(Icons.folder),
//                 title: Text(FileManager.basename(entity)),
//                 onTap: () {
//                   if (FileManager.isDirectory(entity)) {
//                     controller.openDirectory(entity);
//                   } else {
//                     // Perform file-related tasks.
//                     var path = FileManager.basename(entity, true);
//                     AudioManager.instance
//                         .start(
//                             entity.uri.toString(),
//                             // "assets/Rescue-Me.mp3",
//                             // "network format resource"
//                             // "local resource (file://${file.path})"
//                             "title",
//                             desc: "desc",
//                             cover: "assets/onerepublic.jpg")
//                         .then((err) {});
//                   }
//                 },
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

selectStorage(BuildContext context, controller) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: FutureBuilder<List<Directory>>(
        future: FileManager.getStorageList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<FileSystemEntity> storageList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: storageList
                      .map((e) => ListTile(
                            title: Text(
                              "${FileManager.basename(e)}",
                            ),
                            onTap: () {
                              controller.openDirectory(e);
                              Navigator.pop(context);
                            },
                          ))
                      .toList()),
            );
          }
          return Dialog(
            child: CircularProgressIndicator(),
          );
        },
      ),
    ),
  );
}

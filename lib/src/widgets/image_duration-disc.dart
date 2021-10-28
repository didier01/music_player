import 'package:flutter/material.dart';

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
    return Container(
      child: Column(
        children: [
          Text('4:22', style: styleNumber),
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                  width: 3, height: 220, color: Colors.white.withOpacity(0.2)),
              Positioned(
                bottom: 0,
                child: Container(
                    width: 3,
                    height: 100,
                    color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('0:00', style: styleNumber),
        ],
      ),
    );
  }
}

class ImageDisc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: 250,
      height: 250,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image(image: AssetImage('assets/onerepublic.jpg')),
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

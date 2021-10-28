import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 30),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Icon(FontAwesomeIcons.chevronLeft, size: 20.0),
            Spacer(),

            Icon(FontAwesomeIcons.commentAlt, size: 20.0),
            SizedBox(width: 20,),

            Icon(FontAwesomeIcons.headphonesAlt, size: 20.0),
            SizedBox(width: 20,),

            Icon(FontAwesomeIcons.externalLinkAlt, size: 20.0),
            
          ],
        ),
      ),
    );
  }
}

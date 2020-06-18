import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class Tile extends StatelessWidget {

  final Color color;
  final String title;

  Tile({this.color, this.title});

  Tile.empty({this.color}) :title=null;

  Tile.compact({this.color, this.title});


  @override
  Widget build(BuildContext context) {
    return TileBackground(
      color: color,
      child: title != null ? buildTitle(title) : Container(),
    );
  }

  Widget buildTitle(String title) {
    return AutoSizeText(
      title,
      style: TextStyle(fontWeight: FontWeight.bold),
      maxLines: 5,
      minFontSize: 7,
      maxFontSize: 10,
      overflow: TextOverflow.ellipsis,

    );

  }
}


class TileBackground extends StatelessWidget{
  final Color color;
  final Widget child;


  TileBackground({Color color,this.child}): color= color!= null?Color.alphaBlend(color.withAlpha(180), Colors.white) : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.5, 0.5, 0.5, 0.5),
      child: Container(
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color != null ? color : Color.fromARGB(255,230,230,230),
            border: Border.all(width:0.5,color: Colors.black.withAlpha(100))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child != null ? child : Container(),
        ),
      ),
    );
  }
}
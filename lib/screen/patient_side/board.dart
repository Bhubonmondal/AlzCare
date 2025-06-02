import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';

class WhiteBoard extends StatefulWidget {
  const WhiteBoard({super.key});

  @override
  State<WhiteBoard> createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard> {
  late DrawingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DrawingController(

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painting"),
      ),
      body: SafeArea(
        child: DrawingBoard(
          controller: _controller,
          background: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
          ),
          showDefaultActions: true,
          showDefaultTools: true,



        ),
      ),
    );
  }
}

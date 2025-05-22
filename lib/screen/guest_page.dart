import 'package:flutter/material.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _imagePaths = [
    'assets/images/slide1.jpeg',
    'assets/images/slide2.jpeg',
    'assets/images/slide3.jpeg',
    'assets/images/slide4.jpeg',
    'assets/images/slide5.jpg',
  ];

  void _nextPage() {
    if (_currentPage < _imagePaths.length - 1) {
      _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                _imagePaths[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black.withValues(alpha:  0.7),
              ),
              child: Text(
                _currentPage == _imagePaths.length - 1 ? "Go to Login" : "Next",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Text(
              "${_currentPage + 1} / ${_imagePaths.length}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

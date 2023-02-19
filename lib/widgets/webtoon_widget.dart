import 'package:flutter/material.dart';
import 'package:webtoon/screen/detail_screen.dart';
import 'package:webtoon/widgets/thumb_nail_widget.dart';

class Webtoon extends StatelessWidget {
  final String title, thumb, id;
  const Webtoon(
      {super.key, required this.title, required this.thumb, required this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: ((context) => DetailScreen(
                    title: title,
                    thumb: thumb,
                    id: id,
                  )),
            ));
      },
      child: Column(
        children: [
          Hero(
            tag: id,
            child: ThumbNail(thumb: thumb),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

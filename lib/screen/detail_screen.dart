import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webtoon/models/webtoon_detail_model.dart';
import 'package:webtoon/models/webtoon_episode_model.dart';
import 'package:webtoon/services/api_service.dart';
import 'package:webtoon/widgets/thumb_nail_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen(
      {super.key, required this.title, required this.thumb, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;

  bool isHide = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPrefs();
  }

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (likedToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      prefs.setStringList('likedToons', []);
    }
  }

  void onDoubleTap() {
    // 현재 widget을 pop()하여 이전 화면으로 돌아감
    //Navigator.pop(context);
    setState(() {
      isHide = !isHide;
    });
  }

  onButtonTap(String webtoonId, String episodeId) async {
    await launchUrlString(
        "https://comic.naver.com/webtoon/detail?titleId=$webtoonId&no=$episodeId");
  }

  onHeartTap() async {
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        if (likedToons.contains(widget.id) == false) {
          likedToons.add(widget.id);
        }
      }
      await prefs.setStringList('likedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => onDoubleTap(),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.green,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: onHeartTap,
              icon: isLiked
                  ? const Icon(Icons.favorite_rounded)
                  : const Icon(Icons.favorite_outline_rounded),
            ),
          ],
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
            ),
          ),
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
          child: Column(
            children: [
              isHide
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: widget.id,
                          child: ThumbNail(thumb: widget.thumb),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 25,
              ),
              isHide
                  ? Container()
                  : FutureBuilder(
                      future: webtoon,
                      builder: ((context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!.about,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                '${snapshot.data!.genre} / ${snapshot.data!.age}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Column(
                              children: const [
                                SizedBox(
                                  height: 15,
                                ),
                                CircularProgressIndicator(),
                                //Text("..."),
                              ],
                            ),
                          );
                        }
                      }),
                    ),
              const SizedBox(
                height: 10,
              ),
              FutureBuilder(
                future: episodes,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      flex: 1,
                      child: episode(snapshot, widget.id),
                    );
                  } else {
                    return Container();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView episode(
      AsyncSnapshot<List<WebtoonEpisodeModel>> snapshot, String webtoonId) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: ((context, index) {
        return GestureDetector(
          onTap: () => onButtonTap(webtoonId, snapshot.data![index].id),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    snapshot.data![index].title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      separatorBuilder: ((context, index) => const SizedBox(
            height: 5,
          )),
      itemCount: snapshot.data!.length,
    );
  }
}

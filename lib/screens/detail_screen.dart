import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/models/webtoon_detail_model.dart';
import 'package:toonflix/services/api_service.dart';
import 'package:toonflix/models/webtoon_episode_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/episode_widget.dart';


class DetailScreen extends StatefulWidget {
  final String title, thumb, id;


  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPrefs() async{
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');
    if(likedToons != null){
      if(likedToons.contains(widget.id) == true){
        setState(() {
          isLiked = true;
        });
      }
    }
    else{
      await prefs.setStringList('likedToons', []);
    }
  }

  onHeartTap() async {
    final likedToons = prefs.getStringList('likedToons');
    if(likedToons != null){
      if(isLiked){
        likedToons.remove(widget.id);
      }
      else{
        likedToons.add(widget.id);
      }
      await prefs.setStringList('likedToons', likedToons);
      setState(() {});
      isLiked = !isLiked;
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodeById(widget.id);
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title,
        style: const TextStyle(
          fontSize: 24,
        ),
        ),
            foregroundColor: Colors.green,
            backgroundColor: Colors.white,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.white,
            elevation: 2,
            actions: [
              IconButton(
                onPressed: onHeartTap,
                icon: Icon(isLiked ? Icons.favorite_outlined : Icons.favorite_outline_outlined),)
            ],
         ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: widget.id,
                      child: Container(
                        width: 235,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius:15,
                                offset: const Offset(10,10),
                                color: Colors.black.withOpacity(0.5),
                              )
                            ]
                        ),
                        child: Image.network(widget.thumb),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                FutureBuilder(
                    future: webtoon, builder: (context, snapshot) {
                      if(snapshot.hasData){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data!.about,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                            ),
                            const SizedBox(height: 12,),
                            Text('${snapshot.data!.genre} / ${snapshot.data!.age}',
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            FutureBuilder(
                              future: episodes,
                              builder: (context, snapshot) {
                              if(snapshot.hasData){
                                return Column(
                                  children: [
                                    for(var episode in snapshot.data!)
                                      Episode(episode: episode, webtoonId: widget.id),
                                  ],
                                );
                              }
                              return Container();
                            },
                            ),
                          ],
                        );
                      }
                      return const Text("...");
                    },
                )
              ],
            ),
          ),
        ),
    );
  }
}


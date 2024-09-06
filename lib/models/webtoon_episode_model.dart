class WebtoonEpisodeModel{
  final String id, title, rating, date;

  WebtoonEpisodeModel.fromJason(Map<String, dynamic> json):
      id = json['id'],
      title = json['title'],
      rating = json['rating'],
      date = json['date'];
}
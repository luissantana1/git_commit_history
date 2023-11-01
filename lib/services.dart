import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void startServer() async {
  final InternetAddress address = InternetAddress.loopbackIPv4;
  int port = 8080;
  final server = await HttpServer.bind(address, port);

  server.listen( (HttpRequest request){
    if ( request.method == "GET" ) {
      if ( request.connectionInfo!.remoteAddress == address ) {
        request.response.headers.add("Access-Control-Allow-Origin", "http://localhost:4200");
      }//avoid CORS errors 

      if ( request.uri.toString() == "/" ) {
        fetchFromGithub(request);
      }
    }
  });
  print("Server is running at ${address.address} (localhost) on port $port");
}

void fetchFromGithub(request) async {
  final url = "https://api.github.com/repos/luissantana1/git_commit_history/commits";

  try {
    final response = await http.get( Uri.parse(url) );

    if ( response.statusCode != 200 ) {
      request.response.write("Git API Request failed");
      request.response.close();
    }

    final responseBody = jsonDecode(response.body);
    List<Map> commitHistoryData = [];

    for(var element in responseBody) {
      commitHistoryData.add({
        "name": element["commit"]["author"]["name"],
        "username": element["commit"]["author"]["email"],
        "email": element["commit"]["author"]["email"],
        "date":  element["commit"]["author"]["date"],
        "comment": element["commit"]["message"].toString(),
      });
    }

    request.response.write(jsonEncode(commitHistoryData));
    request.response.close();

  } catch(e) {
    print(e);
    request.response.write("Internal server error");
    request.response.close();
  }
}

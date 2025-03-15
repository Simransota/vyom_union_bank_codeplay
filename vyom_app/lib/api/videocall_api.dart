import 'dart:convert';
import 'package:http/http.dart' as http;

String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiI4OTQ0ZWMyNy1mNDIzLTQ4ZGEtYWRiOS02N2JhNjA1YjY5Y2QiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTc0MTE3NzYxMiwiZXhwIjoxNzQ4OTUzNjEyfQ.HlRIWM-Qr9vCp0lcAf3E5MX_vjhPFn3y1hqpo0FwxOg";

Future<String> createRoom() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': token},
  );

  return json.decode(httpResponse.body)['roomId'];
}

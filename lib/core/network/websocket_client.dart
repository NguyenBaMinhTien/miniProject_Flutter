import '../socket/live_socket_service.dart';

@Deprecated('Use LiveSocketService')
class WebSocketClient extends LiveSocketService {
  WebSocketClient({String url = 'ws://localhost:3000'}) : super(url: url);
}

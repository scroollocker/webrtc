typedef ConnectAction = void Function();
typedef DisconnectAction = void Function();
typedef OnInitCallback = void Function();

class WebrtcController {
  ConnectAction? connect;
  DisconnectAction? disconnect;
  OnInitCallback? onInitCallback;
}

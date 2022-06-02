let
  sebas_wc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfN08jC7Rkmnbk2wE1UVuLUalQQU+yYi2017RZ7OcBD";
  chat_server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9erUSKCBMmaywd8vEXTxtKENnnIpIlmwDahKuHFrWa";
in rec {
  inherit sebas_wc chat_server;
  users = [
    sebas_wc
  ];
  systems = [
    chat_server
  ];
  all = users ++ systems;
}

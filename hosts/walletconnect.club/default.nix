{...}: let
  conduitPort = "6167";
  domain = "walletconnect.club";
in {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  system.stateVersion = "22.05";
  users.users.root.openssh.authorizedKeys.keys = (import ../../secrets/keys.nix).users;

  networking.firewall.allowedTCPPorts = [80 443 8448];
  networking.firewall.enable = true;

  services.matrix-conduit = {
    enable = true;
    settings.global = {
      address = "127.0.0.1";
      allow_registration = true;
      database_backend = "sqlite";
      server_name = domain;
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "ops@walletconnect.com";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
    http2 = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 8448;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 8448;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 443;
        ssl = true;
      }
      {
        addr = "0.0.0.0";
        port = 80;
      }
      {
        addr = "[::0]";
        port = 80;
      }
    ];
    locations."/_matrix/" = {
      proxyPass = "http://127.0.0.1:${conduitPort}$request_uri";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_buffering off;
      '';
    };
  };
}

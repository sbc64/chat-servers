{
  config,
  lib,
  ...
}: let
  matrixPort = "8008";
  domain = "walletconnect.club";
  allIpv4 = "0.0.0.0";
  allIpv6 = "[::0]";
  dendritePKPath = "/var/lib/dendrite/pk";
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

  users.groups.dendrite = {};
  users.users."dendrite" = {
    group = "dendrite";
    isSystemUser = true;
  };
  age.secrets = {
    "dendrite-service".file = ../../secrets/dendrite-service.age;
    "dendrite-private_key.age" = {
      file = ../../secrets/dendrite-private_key.age;
      path = dendritePKPath;
      owner = "dendrite";
    };
  };
  # TODO Convert this to dendrite user and make the dendedrit
  #systemd.services.dendrite.serviceConfig.User = lib.mkForce "dendrite";
  services.dendrite = {
    enable = true;
    openRegistration = true;
    environmentFile = config.age.secrets.dendrite-service.path;
    settings = {
      client_api = {
        #registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
        registration_disabled = false;
      };
      global = {
        private_key = dendritePKPath;
        server_name = domain;
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "ops@walletconnect.com";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."${domain}" = {
    extraConfig = ''
      proxy_set_header Host      $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_read_timeout         600;
    '';
    enableACME = true;
    forceSSL = true;
    http2 = true;
    listen = [
      {
        addr = allIpv4;
        port = 8448;
        ssl = true;
      }
      {
        addr = allIpv6;
        port = 8448;
        ssl = true;
      }
      {
        addr = allIpv4;
        port = 443;
        ssl = true;
      }
      {
        addr = allIpv6;
        port = 443;
        ssl = true;
      }
      {
        addr = allIpv4;
        port = 80;
      }
      {
        addr = allIpv6;
        port = 80;
      }
    ];
    # https://github.com/matrix-org/synapse/blob/develop/docs/setup/installation.md#client-well-known-uri
    locations = {
      "/.well-known/matrix/server".extraConfig = ''
        return 200 '{ "m.server": "${domain}:443" }';
      '';
      "/.well-known/matrix/client".extraConfig = ''
        return 200 '{ "m.homeserver": { "base_url": "https://${domain}" } }';
      '';
      "/_matrix/" = {
        proxyPass = "http://127.0.0.1:${matrixPort}$request_uri";
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };
}

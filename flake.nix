{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    /*
     nixos-generators = {
       url = "github:nix-community/nixos-generators";
       inputs.nixpkgs.follows = "nixpkgs";
     };
     */
    agenix.url = "github:ryantm/agenix";
  };
  outputs = {
    self,
    nixpkgs,
    #nixos-generators,
    deploy-rs,
    agenix,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        deploy-rs.packages.x86_64-linux.deploy-rs
        agenix.packages.x86_64-linux.agenix
      ];
    };

    nixosConfigurations = {
      "walletconnect-club" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({config, ...}: {
            networking.hostName = "walletconnect-club";
          })
          ./hosts/walletconnect.club
          agenix.nixosModule
        ];
      };
    };

    deploy.nodes = {
      "walletconnect-club" = {
        #hostname = "164.92.142.84";
        hostname = "walletconnect.club";
        sshUser = "root";
        fastConnection = true;
        profiles.system = {
          user = "root";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations."walletconnect-club";
        };
      };
    };

    /*
     packages.x86_64-linux = {
       do = nixos-generators.nixosGenerate {
         pkgs = nixpkgs.legacyPackages.x86_64-linux;
         modules = [
           ({config, ...}: {
             services.openssh = {
               enable = true;
               permitRootLogin = "yes";
             };
             system.stateVersion = "22.05";
             users.users."root".openssh.authorizedKeys.keys = (import ./secrets/keys.nix).users;
           })
         ];
         format = "do";
       };
     };
     */
    checks =
      builtins.mapAttrs
      (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib;
  };
}

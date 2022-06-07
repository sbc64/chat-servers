let
  keys = import ./keys.nix;
in {
  "dendrite-service.age".publicKeys = keys.all;
  "dendrite-private_key.age".publicKeys = keys.all;
}

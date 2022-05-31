let
  keys = import ./keys.nix;
in {
  "secret1.age".publicKeys = keys.all;
  "turris-psk.age".publicKeys = keys.all;
}

let
  keys = import ./keys.nix;
in {
  "dendrite-service".publicKeys = keys.all;
}

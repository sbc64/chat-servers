let
  keys = import ./keys.nix;
in {
  "dendrite-service.age".publicKeys = keys.all;
}

{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "164.92.128.1";
    defaultGateway6 = "2a03:b0c0:3:d0::1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="164.92.142.84"; prefixLength=20; }
{ address="10.19.0.8"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2a03:b0c0:3:d0::18f2:b001"; prefixLength=64; }
{ address="fe80::d079:39ff:fead:d5a3"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "164.92.128.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "2a03:b0c0:3:d0::1"; prefixLength = 128; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="d2:79:39:ad:d5:a3", NAME="eth0"
    ATTR{address}=="32:46:5f:c0:75:88", NAME="eth1"
  '';
}

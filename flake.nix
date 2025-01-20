{
  description = "Custom liveCD";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nvim-config.url = "github:Khelda/nvim-config";
    zshrc.url = "github:Khelda/zshrc.d";
  };

  outputs = { self, nixpkgs, nvim-config, zshrc, ... }:
    let system = "x86_64-linux";
    in {
      nixosConfigurations = {
        daeser = nixpkgs.lib.nixosSystem {
          system = "${system}";
          modules = [
            ({ pkgs, modulesPath, ... }: {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
              ];
              environment.systemPackages = with nixpkgs; [
                nvim-config.packages."${system}".neovim-full-offline
                zshrc.packages."${system}".zsh-full-offline
              ];
              programs.zsh.enable = true;
            })
          ];
        };

        systemd.services.sshd.wantedBy =
          nixpkgs.lib.mkForce [ "multi-user.target" ];
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyyw2If1cVfj4x/yB7JqU8z9hGIVtxl+3lrdYeghgcj kheldae@caathven"
        ];

        networking = {
          usePredictableInterfaceNames = false;
          interfaces.eth0.ipv4.addresses = [{
            address = ""; # TODO fix address
            prefixLength = 24;
          }];
          defaultGateway = ""; # TODO find gateway address
          nameservers = [ "8.8.8.8" ];
        };
      };
    };
}

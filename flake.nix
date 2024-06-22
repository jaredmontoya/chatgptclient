{
  description = "OpenAI API compatible GTK4 chat client";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            nim
            nimble

            pkg-config

            (writeShellScriptBin "lock" ''
              nimble lock
              ${nim_lk}/bin/nim_lk nimble-to-nix > lock.json
            '')

            (writeShellScriptBin "update" ''
              nimble upgrade
              ${nim_lk}/bin/nim_lk nimble-to-nix > lock.json
            '')
          ];

          buildInputs = with pkgs; [ openssl gtk4 libadwaita ];

          shellHook = ''
            echo -e "\033[0;32;4mHeper commands:\033[0m"
            echo "'lock' instead of 'nimble lock'"
            echo "'update' instead of 'nimble upgrade'"
          '';
        };

        packages.default = pkgs.buildNimPackage {
          pname = "chatgptclient";
          version = "0.2.0";
          src = self;

          nativeBuildInputs = with pkgs; [ pkg-config ];

          buildInputs = with pkgs; [ openssl gtk4 libadwaita ];

          lockFile = ./lock.json;

          meta = with pkgs.lib; {
            description = "OpenAI API compatible GTK4 chat client";
            homepage = "https://github.com/jaredmontoya/chatgptclient";
            license = licenses.gpl3Plus;
            maintainers = with maintainers; [ jaredmontoya ];
            platforms = platforms.linux;
            mainProgram = "chatgptclient";
          };
        };
      });
}

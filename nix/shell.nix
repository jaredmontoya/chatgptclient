{ pkgs }:

{
  default = pkgs.mkShell {
    nativeBuildInputs = with pkgs; [
      nim
      nimble

      pkg-config

      (writeShellScriptBin "lock" ''
        nimble lock
        ${nim_lk}/bin/nim_lk nimble-to-nix > nix/pkgs/chatgptclient/lock.json
      '')

      (writeShellScriptBin "update" ''
        nimble upgrade
        ${nim_lk}/bin/nim_lk nimble-to-nix > nix/pkgs/chatgptclient/lock.json
      '')
    ];

    buildInputs = with pkgs; [
      openssl
      gtk4
      libadwaita
    ];

    shellHook = ''
      echo -e "\033[0;32;4mHeper commands:\033[0m"
      echo "'lock' instead of 'nimble lock'"
      echo "'update' instead of 'nimble upgrade'"
    '';
  };
}

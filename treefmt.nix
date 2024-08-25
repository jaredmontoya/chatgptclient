{
  projectRootFile = "flake.nix";

  programs = {
    deadnix.enable = true;
    statix.enable = true;
    nixfmt.enable = true;

    nimpretty.enable = true;
  };
}

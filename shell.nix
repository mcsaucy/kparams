{ pkgs ? import <nixpkgs> {}
}:

pkgs.mkShell {
  name = "dev-environment";
  buildInputs = with pkgs; [
    zsh bash dash ksh
  ];

}

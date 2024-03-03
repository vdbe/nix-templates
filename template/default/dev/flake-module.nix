{ inputs, ... }: {
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = { self', config, pkgs, ... }:
    let
      treefmtRuntimeInputs = with pkgs; [
        treefmt
      ];

      treefmtWrapper = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = treefmtRuntimeInputs;
        text =
          ''
            exec treefmt "$@"
          '';
      };
    in
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';

        nativeBuildInputs = treefmtRuntimeInputs ++ (with pkgs; [
        ]);

        inputsFrom = builtins.attrValues (self'.packages or [ ]);
      };

      formatter = treefmtWrapper;

      pre-commit = {
        check.enable = true;

        settings = {
          excludes = [ "flake.lock" ];
          settings.treefmt.package = treefmtWrapper;

          hooks = {
            treefmt.enable = true;
          };
        };
      };
    };
}

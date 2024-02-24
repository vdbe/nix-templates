{ inputs, ... }: {
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem = { config, pkgs, ... }:
    let
      treefmtRuntimeInputs = with pkgs; [
        treefmt
        deadnix
        statix
        nixpkgs-fmt
        taplo
        shellcheck
        shfmt
        nodePackages.prettier
      ];

      treefmtWrapper = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = treefmtRuntimeInputs;
        text =
          ''
            exec treefmt "$@"
          '';
      };

      checkFlakes = pkgs.writeShellApplication {
        name = "check-flakes";
        meta.descriptions = "Check all flakes passed as argument";
        runtimeInputs = [ pkgs.nix ];
        text = builtins.readFile ./scripts/check-flakes.sh;
      };

    in
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';

        nativeBuildInputs = treefmtRuntimeInputs ++ (with pkgs; [
          nixd
          yaml-language-server
        ]);
      };

      formatter = treefmtWrapper;

      packages.check-flakes = checkFlakes;

      pre-commit = {
        # Unable to run since it tries to access github
        check.enable = false;

        settings = {
          excludes = [ "flake.lock" ];
          settings.treefmt.package = treefmtWrapper;

          hooks = {
            treefmt.enable = true;

            asdf = {
              enable = true;
              name = "Check template flakes";
              files = ".*flake\\.nix$";
              entry = "${checkFlakes}/bin/check-flakes";
            };
          };
        };
      };
    };
}





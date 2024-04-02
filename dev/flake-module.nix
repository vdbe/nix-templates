{ inputs, ... }: {
  imports = [
    inputs.pre-commit-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = { self', config, pkgs, lib, ... }:
    {
      devShells.default = pkgs.mkShell {
        shellHook = ''
          ${config.pre-commit.installationScript}
        '';

        packages = with pkgs; [
          deadnix
          statix
          nixpkgs-fmt
          nixd

          mdsh
          shellcheck

          self'.formatter
        ];

        inputsFrom = builtins.attrValues (self'.packages or [ ]);
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          deadnix.enable = true;
          statix.enable = true;
          nixpkgs-fmt.enable = true;

          shellcheck.enable = true;
          shfmt.enable = true;

          mdsh.enable = true;
        };
      };

      pre-commit = {
        check.enable = true;

        settings = {
          excludes = [ "flake.lock" ];

          hooks = {
            treefmt = {
              enable = true;
              package = self'.formatter;
            };
          };
        };
      };

      formatter = config.treefmt.build.wrapper;


      checks =
        let
          packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
          devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
        in
        packages // devShells;
    };
}



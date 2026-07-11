{
  description = "Strudel live-coding REPL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        src = pkgs.fetchFromGitea {
          domain = "codeberg.org";
          owner = "uzu";
          repo = "strudel";
          rev = "c15075237263c39e516301a1ff0fdc0b4c1bc04f";
          hash = "sha256-5fxkR/6eSDp/1SOhOMg3tE8pMQFXvu/AXIDsnKn+Di8=";
        };

        pnpmDeps = pkgs.fetchPnpmDeps {
          pname = "strudel";
          version = "0.5.0";
          fetcherVersion = 4;
          inherit src;
          hash = "sha256-82wKdwIkhoQq5LY/3m9ZZtQAR23vcnN7UVoHWThBxnQ=";
        };

        strudelWebsite = pkgs.stdenv.mkDerivation {
          pname = "strudel-website";
          version = "0.6.0";
          inherit src pnpmDeps;

          nativeBuildInputs = [
            pkgs.nodejs_22
            pkgs.pnpm
            pkgs.pnpmConfigHook
          ];

          buildPhase = ''
            pnpm jsdoc-json
            cd website && pnpm build
          '';

          installPhase = ''
            cp -r dist $out
          '';
        };

        strudelApp = pkgs.writeShellScriptBin "strudel" ''
          PORT=''${PORT:-3009}
          ${pkgs.python3}/bin/python3 -m http.server "$PORT" \
            --directory ${strudelWebsite} &
          PID=$!
          sleep 1
          echo "Strudel REPL -> http://localhost:$PORT"
          if command -v xdg-open &>/dev/null; then
            xdg-open "http://localhost:$PORT"
          elif command -v open &>/dev/null; then
            open "http://localhost:$PORT"
          fi
          wait $PID
        '';

      in {
        packages.default = strudelWebsite;

        apps.default = {
          type = "app";
          program = "${strudelApp}/bin/strudel";
        };
      }
    );
}

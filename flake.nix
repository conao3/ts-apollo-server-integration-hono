{
  description = "Apollo Server integration for Hono";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, ... }:
        let
          nodejs = pkgs.nodejs_26;
          pnpm = pkgs.pnpm.override { nodejs-slim = pkgs.nodejs-slim_26; };

          vp = pkgs.writeShellApplication {
            name = "vp";
            runtimeInputs = [
              nodejs
              pnpm
            ];
            text = ''
              workspace_root="$PWD"
              while [[ "$workspace_root" != / && ! -f "$workspace_root/pnpm-workspace.yaml" ]]; do
                workspace_root="$(dirname "$workspace_root")"
              done

              if [[ ! -f "$workspace_root/pnpm-workspace.yaml" ]]; then
                printf '%s\n' "vp must run inside the apollo-server-integration-hono workspace" >&2
                exit 1
              fi

              if [[ "''${1:-}" == install ]]; then
                shift
                exec pnpm install "$@"
              fi

              vp_cli="$workspace_root/node_modules/vite-plus/bin/vp"
              if [[ ! -f "$vp_cli" ]]; then
                printf '%s\n' "The local Vite+ CLI is missing; run 'vp install' first" >&2
                exit 1
              fi

              export PATH="${nodejs}/bin:$workspace_root/node_modules/.bin:$PATH"
              exec ${nodejs}/bin/node "$vp_cli" "$@"
            '';
          };

          build = pkgs.stdenv.mkDerivation (finalAttrs: {
            pname = "apollo-server-integration-hono";
            version = (pkgs.lib.importJSON ./package.json).version;
            src = self;

            pnpmDeps = pkgs.fetchPnpmDeps {
              inherit (finalAttrs) pname version src;
              inherit pnpm;
              fetcherVersion = 5;
              hash = "sha256-e2pwCTeNlAIDe7F0MnsdjJQ2LAd3s3yUBYWVeF33f5w=";
            };

            nativeBuildInputs = [
              nodejs
              pnpm
              pkgs.pnpmConfigHook
            ];

            buildPhase = ''
              runHook preBuild
              export PATH="${nodejs}/bin:$PWD/node_modules/.bin:$PATH"
              ${nodejs}/bin/node "$PWD/node_modules/vite-plus/bin/vp" pack
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/lib $out/share/example
              cp -r dist package.json README.md LICENSE $out/lib/
              cp example/dist/server.mjs $out/share/example/
              runHook postInstall
            '';
          });

          example = pkgs.writeShellApplication {
            name = "apollo-server-integration-hono-example";
            text = ''exec ${nodejs}/bin/node ${build}/share/example/server.mjs "$@"'';
          };
        in
        {
          packages = {
            inherit build;
            default = example;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              nodejs
              pnpm
              vp
            ];
          };

          treefmt.programs.nixfmt.enable = true;
        };
    };
}

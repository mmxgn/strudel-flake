# strudel-flake

Nix flake for [Strudel](https://codeberg.org/uzu/strudel), a browser-based live coding environment for algorithmic music patterns, porting [TidalCycles](https://tidalcycles.org) to JavaScript.

Try it online at **https://strudel.cc**

## Run directly

```bash
nix run github:mmxgn/strudel-flake
```

Opens the Strudel REPL at `http://localhost:3009` in your browser. Set `PORT` to use a different port:

```bash
PORT=8080 nix run github:mmxgn/strudel-flake
```

## Install in your NixOS configuration

Add the flake as an input and include the package in your system or home config.

### flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    strudel.url = "github:mmxgn/strudel-flake";
  };

  outputs = { self, nixpkgs, strudel, ... } @ inputs:
  {
    nixosConfigurations."<yourhostname>" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        {
          environment.systemPackages = [
            strudel.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
```

Or with Home Manager:

```nix
home.packages = [ inputs.strudel.packages.x86_64-linux.default ];
```

After installing, run with:

```bash
strudel
```

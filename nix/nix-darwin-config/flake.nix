{
  description = "Berto Darwin Nix with Homebrew";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
  let
    system = "aarch64-darwin";  
    home = "/Users/berto";
 pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (self: super: {
          sqlite = super.sqlite.overrideAttrs (old: {
            version = "3.34.0";
            src = super.fetchurl {
              url = "https://www.sqlite.org/2020/sqlite-autoconf-3340000.tar.gz";
              sha256 = "0xw9w4kcj65f85i7r9z1l9k0axjklgj8wvb4gnz5mf3j9lnhr1ib";
            };
          });
        })
      ];
      config.allowUnfree = true;
    };
  in {
    darwinConfigurations = {
      berto = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          # nix-homebrew.darwinModules.homebrew-taps

          {
            nix-homebrew = {
              enable = true;            # Enable Homebrew installation
              enableRosetta = true;     # Enable Rosetta for Apple Silicon
              user = "berto";           # Replace with your username
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
              mutableTaps = false;      # Only declarative taps
              autoMigrate = true;       # Automatically migrate existing Homebrew installations

              # Add Bitwarden to the list of packages to be installed via Homebrew
            };

            nixpkgs.config.allowUnfree = true;  # Allow unfree packages

            environment.systemPackages = with pkgs; [
              vim
	      iterm2
              neovim
              slack
              discord
	      stow
              ripgrep
              sqlite
            ];

            services.nix-daemon.enable = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
            programs.zsh.enable = true;

            # Set the system state version
            system.stateVersion = 5;  # Adjust to your NixOS version
          }
	  {
	   homebrew = {
	    enable = true;
	    global = {
	      autoUpdate = true;
	    };
	    onActivation = {
	      autoUpdate = true;
	      upgrade = true;
	      cleanup = "zap";
	    };
            brews = [
              "libpq"
            ];
	    casks = [
	      "bitwarden"
	      "firefox@developer-edition"
	      "firefox"
	      "google-chrome"
	      "dropbox"
	    ];
  	  };
	 }
        ];
      };
    };
  };
}


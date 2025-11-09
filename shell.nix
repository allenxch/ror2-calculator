{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "ror2-calculator";
  
  buildInputs = with pkgs; [
    # PureScript toolchain
    nodejs
    purescript
    spago
    
    # JavaScript bundler for the final web page
    # parcel-bundler
    
    # Development tools
    nodePackages.purescript-psa
    nodePackages.purs-tidy
    nodePackages.bower
    
    # Optional: Language server for editor support
    nodePackages.purescript-language-server
  ];

  # Environment variables
  shellHook = ''
    echo "=== Risk of Rain 2 Damage Calculator Environment ==="
    echo "PureScript $(purs --version)"
    echo "Spago $(spago version)"
    echo "Node.js $(node --version)"
    echo ""
    echo "Available commands:"
    echo "  spago build    - Build the project"
    echo "  spago test     - Run tests"
    echo "  spago run      - Run the project"
    echo "  parcel build   - Build for web deployment"
    echo ""
    
    # Check if this is a new project and initialize if needed
    if [ ! -f "spago.dhall" ]; then
      echo "Setting up new PureScript project..."
      spago init
    fi
    
    # Build the project on shell entry
    if [ -f "spago.dhall" ]; then
      echo "Building project..."
      spago build
    fi
  '';
}

{
  description = "playwright + webkit + github action experiment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
            };
          }
        );
    in
    {
      devShells = forEachSystem (
        { pkgs }:
        let
          mesaEglVendorFile = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";
        in
        {
          default = pkgs.mkShell ({
            buildInputs = [
              pkgs.nodejs_25
              pkgs.nil
              pkgs.pnpm
              pkgs.playwright-test
              pkgs.playwright-driver.browsers
            ];
            PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
            PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 1;
            PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = 1;
          } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            __EGL_VENDOR_LIBRARY_FILENAMES = mesaEglVendorFile;
          });
        }
      );
    };
}

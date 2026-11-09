{pkgs-unstable, ...}: {
  services.caddy.enable = true;
  services.caddy.package = pkgs-unstable.caddy.withPlugins {
    plugins = ["github.com/mholt/caddy-l4@v0.1.2"];
    hash = "sha256-FwGmHobFqBkEI7LN/YaPsL0t+dJn8uZMhCp9asDEsYw=";
  };
}

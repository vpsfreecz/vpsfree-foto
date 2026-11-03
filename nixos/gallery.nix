{ config, lib, pkgs, ... }:
let
  cfg = config.services.vpsfreePhotoShow;
  app = import ../photoshow/package.nix { inherit pkgs; };
  php = import ../photoshow/runtime.nix { inherit pkgs; };
in {
  options.services.vpsfreePhotoShow = {
    enable = lib.mkEnableOption "the original PhotoShow gallery on current PHP";
    hostName = lib.mkOption { type = lib.types.str; default = "foto.vpsfree.cz"; };
    user = lib.mkOption { type = lib.types.str; default = "foto"; };
    group = lib.mkOption { type = lib.types.str; default = "foto"; };
    photosDir = lib.mkOption { type = lib.types.str; default = "/var/www/foto.vpsfree.cz/fotky_galerie"; };
    generatedDir = lib.mkOption { type = lib.types.str; default = "/var/www/foto.vpsfree.cz/fotky_thumbs"; };
    stateDir = lib.mkOption { type = lib.types.str; default = "/var/lib/photoshow"; };
    trustedProxyAddresses = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  };
  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = { isSystemUser = true; group = lib.mkDefault cfg.group; };
    users.groups.${cfg.group} = {};
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.stateDir}/sessions 0700 ${cfg.user} ${cfg.group} -"
      "d ${cfg.stateDir}/auth-throttle 0700 ${cfg.user} ${cfg.group} -"
      "e ${cfg.stateDir}/auth-throttle - - - 1d"
    ];
    # Preserve the existing gallery pool, identity, socket and worker settings.
    services.phpfpm.pools.foto = {
      user = cfg.user;
      group = cfg.group;
      phpPackage = php;
      phpEnv = {
        PHOTOSHOW_PUBLIC_URL = "https://${cfg.hostName}/";
        PHOTOSHOW_BASE_PATH = "/";
        PHOTOSHOW_PHOTOS_DIR = cfg.photosDir;
        PHOTOSHOW_GENERATED_DIR = cfg.generatedDir;
        PHOTOSHOW_STATE_DIR = cfg.stateDir;
      };
      settings = {
        pm = "dynamic";
        "listen.owner" = config.services.nginx.user;
        "pm.max_children" = 5;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
        "pm.max_requests" = 500;
        "php_admin_value[session.save_path]" = "${cfg.stateDir}/sessions";
        "php_admin_flag[display_errors]" = "off";
        "php_admin_flag[log_errors]" = "on";
      };
    };
    services.nginx.virtualHosts.${cfg.hostName} = {
      enableACME = false;
      forceSSL = false;
      root = app;
      extraConfig = ''
        client_max_body_size 64m;
        ${lib.concatMapStringsSep "\n" (ip: "set_real_ip_from ${ip};") cfg.trustedProxyAddresses}
        real_ip_header X-Real-IP;
      '';
      locations = {
        "= /".extraConfig = "rewrite ^ /index.php last;";
        "= /index.php".extraConfig = ''
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME ${app}/index.php;
          fastcgi_param HTTPS on;
          fastcgi_param HTTP_PROXY "";
          fastcgi_pass unix:${config.services.phpfpm.pools.foto.socket};
          fastcgi_read_timeout 70s;
          fastcgi_hide_header X-Powered-By;
        '';
        "~ ^/(?:inc|src/(?:stylesheets|js)|user/themes)/[^?]+\\.(?:css|js|png|jpg|jpeg|gif|ico|woff2?|ttf|otf|eot|svg)$".extraConfig = ''
          try_files $uri =404;
          add_header X-Content-Type-Options nosniff always;
        '';
        "/".return = "404";
      };
    };
  };
}

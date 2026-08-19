{
  config,
  lib,
  pkgs,
  ...
} : let
  cfg = config.services.duckdns;

in {
  options.services.duckdns = {
    enable = lib.mkEnableOption "DuckDNS updater";

    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        List of DuckDNS domains to update.
        Cannot be used together with `domainsFile`.
      '';
    };

    domainsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing users DuckDNS domains (seperated with comma, no spaces).
        Cannot be used together with `domains`.
      '';
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a file containing the DuckDNS API token.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.duckdns = {
      isSystemUser = true;
      group = "duckdns";
    };

    users.groups.duckdns = {};

    systemd.services.duckdns-updater = {
      description = "DuckDNS Updater";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "duckdns";
        Group = "duckdns";
        TimeoutStartSec = 60;
      };
      script = ''
        set -euo pipefail
        
        IP=$(${pkgs.dig}/bin/dig +short myip.opendns.com @resolver1.opendns.com)
        TOKEN="$(${pkgs.coreutils}/bin/cat '${cfg.tokenFile}')"

        if [ -n '${cfg.domainsFile}' ]; then
          DOMAINS="$(${pkgs.coreutils}/bin/cat '${cfg.domainsFile}' | ${pkgs.coreutils}/bin/tr '\n' ',')"
          DOMAINS="''${DOMAINS%,}"
        else
          DOMAINS="${lib.concatStringsSep "," cfg.domains}"
        fi

        ${pkgs.curl}/bin/curl -sS -4 "https://www.duckdns.org/update?domains=''${DOMAINS}&token=''${TOKEN}&ip=''${IP}"
      '';
    };

    systemd.timers.duckdns-updater = {
      description = "Timer for DuckDNS Updater";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnBootSec = "15min";
        OnUnitActiveSec = "15min";
        Unit = "duckdns-updater.service";
      };
    };

    assertions = [
      {
        assertion = !(cfg.domains != [] && cfg.domainsFile != null);
        message = "services.duckdns.domains and services.duckdns.domainsFile cannot both be set";
      }
      {
        assertion = cfg.domains != [] || cfg.domainsFile != null;
        message = "services.duckdns: you must set either `domains` or `domainsFile`";
      }
      {
        assertion = cfg.tokenFile != null;
        message = "services.duckdns.tokenFile must be set when `enable` is true";
      }
    ];
  
  };}

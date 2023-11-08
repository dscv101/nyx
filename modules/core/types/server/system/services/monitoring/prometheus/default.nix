{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;

  dev = config.modules.device;
  cfg = config.modules.system.services;
  acceptedTypes = ["server" "hybrid"];
in {
  config = mkIf ((builtins.elem dev.type acceptedTypes) && cfg.monitoring.prometheus.enable) {
    services = {
      # Prometheus exporter for Grafana
      prometheus = {
        enable = true;
        port = 9100;
        globalConfig = {
          scrape_interval = "10s";
          scrape_timeout = "2s";
        };

        # enabled exporters
        exporters = {
          node = {
            enable = true;
            port = 9101;
          };

          redis = {
            enable = true;
            port = 9102;
            user = "redis";
          };

          postgres = {
            enable = true;
            port = 9103;
            user = "postgres";
          };

          nginx = {
            enable = false;
            port = 9104;
          };
        };

        scrapeConfigs = [
          # internal scrape jobs
          {
            job_name = "prometheus";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9100"];}];
          }
          {
            job_name = "node";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9101"];}];
          }
          {
            job_name = "redis";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9102"];}];
          }
          {
            job_name = "postgres";
            scrape_interval = "30s";
            static_configs = [{targets = ["localhost:9103"];}];
          }
          /*
          {
            job_name = "nginx";
            static_configs = [
              {
                targets = ["127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"];
              }
            ];
          }
          */
          # TODO: exterenal scrape jobs - over tailscale/wireguard mesh
        ];
      };
    };
  };
}

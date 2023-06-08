{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  device = config.modules.device;
  cfg = config.modules.services.override;
  acceptedTypes = ["server" "hybrid"];
in {
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  config = mkIf (builtins.elem device.type acceptedTypes && !cfg.mailserver) {
    # required for roundcube
    networking.firewall.allowedTCPPorts = [80 443];

    postfix = {
      dnsBlacklists = [
        "all.s5h.net"
        "b.barracudacentral.org"
        "bl.spamcop.net"
        "blacklist.woody.ch"
      ];
      dnsBlacklistOverrides = ''
        ataraxiadev.com OK
        mail.ataraxiadev.com OK
        127.0.0.0/8 OK
        192.168.0.0/16 OK
      '';
      headerChecks = [
        {
          action = "IGNORE";
          pattern = "/^User-Agent.*Roundcube Webmail/";
        }
      ];
    };

    services.roundcube = {
      enable = true;
      # this is the url of the vhost, not necessarily the same as the fqdn of
      # the mailserver
      hostName = "webmail.notashelf.dev";
      extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };

    mailserver = {
      enable = true;
      mailDirectory = "/srv/mail/vmail";
      dkimKeyDirectory = "/srv/mail/dkim";
      openFirewall = true;
      enableImap = true;
      enableImapSsl = true;
      enablePop3 = false;
      enablePop3Ssl = false;
      enableSubmission = false;
      enableSubmissionSsl = true;
      hierarchySeparator = "/";
      localDnsResolver = false;
      fqdn = "mail.notashelf.dev";
      certificateScheme = "acme-nginx";
      domains = ["notashelf.dev"];
      loginAccounts = {
        "raf@notashelf.dev" = {
          hashedPasswordFile = config.age.secrets.mailserver-secret.path;
          aliases = ["raf" "me@notashelf.dev" "admin" "admin@notashelf.dev" "root" "root@notashelf.dev" "postmaster@notashelf.dev"];
        };

        "gitea@notashelf.dev" = {
          aliases = ["gitea"];
          hashedPasswordFile = config.age.secrets.mailserver-gitea-secret;
        };

        "vaultwarden@notashelf.dev" = {
          aliases = ["vaultwarden"];
          hashedPasswordFile = config.age.secrets.mailserver-vaultwarden-secret;
        };

        "matrix@notashelf.dev" = {
          aliases = ["matrix"];
          hashedPasswordFile = config.age.secrets.mailserver-matrix-secret;
        };

        "cloud@notashelf.dev" = {
          aliases = ["matrix"];
          hashedPasswordFile = config.age.secrets.mailserver-cloud-secret;
        };
      };

      fullTextSearch = {
        enable = true;
        # index new email as they arrive
        autoIndex = true;
        # this only applies to plain text attachments, binary attachments are never indexed
        indexAttachments = true;
        enforced = "body";
      };
    };
  };
}

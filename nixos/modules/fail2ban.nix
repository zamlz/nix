_: {
  services.fail2ban = {
    enable = true;

    # Ban for 30 minutes after 5 failures within 10 minutes
    maxretry = 5;
    bantime = "30m";
    bantime-increment.enable = true;

    jails.sshd = {
      settings = {
        enabled = true;
        port = "ssh";
        filter = "sshd";
        maxretry = 3;
      };
    };
  };
}

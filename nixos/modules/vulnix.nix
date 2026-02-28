# Vulnix — CVE vulnerability scanner for NixOS.
# Runs daily via systemd timer, scans /run/current-system closure against
# the NIST NVD, and exports results as a Prometheus metric via the
# node_exporter textfile collector.
#
# Debugging:
#   systemctl start vulnix-scan    # trigger manually
#   systemctl status vulnix-scan   # check last run
#   cat /var/lib/vulnix/report.txt # full human-readable report
#   cat /var/lib/prometheus-node-exporter/textfile/vulnix.prom  # metric
{ pkgs, ... }:
let
  textfileDir = "/var/lib/prometheus-node-exporter/textfile";
  reportDir = "/var/lib/vulnix";
in
{
  systemd.services.vulnix-scan = {
    description = "Scan NixOS system for known CVEs";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.vulnix ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "vulnix";
    };
    script = ''
      # Run vulnix and capture output (exits non-zero when CVEs found)
      report=$(vulnix --system 2>&1) || true
      echo "$report" > ${reportDir}/report.txt

      # Count unique CVEs from the report
      cve_count=$(echo "$report" | grep -c '^CVE-' || true)

      # Write Prometheus metric
      cat > ${textfileDir}/vulnix.prom <<EOF
      # HELP vulnix_cve_count Number of CVEs found by vulnix scan
      # TYPE vulnix_cve_count gauge
      vulnix_cve_count $cve_count
      EOF
    '';
  };

  systemd.timers.vulnix-scan = {
    description = "Daily CVE vulnerability scan";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "4h";
      Persistent = true;
    };
  };
}

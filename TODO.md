Homelab Best Practices Audit
=============================

Critical Missing Pieces
-----------------------

1. No Secrets Management
   This is the biggest gap. Hardcoded SSH keys, an initial password of
   "pleasechangeme" in users.nix, and no encrypted secrets solution.
   Options:
   - sops-nix (recommended, integrates with existing GPG setup)
   - agenix (simpler, SSH-key based)
   This would let you encrypt WiFi passwords, service credentials, API
   keys, etc. and commit them safely to the repo.

2. No Deployment Tooling
   Manual nixos-rebuild switch on each machine. With 4 NixOS hosts,
   consider:
   - deploy-rs — declarative, supports rollback on failure, can deploy
     to all hosts from one machine
   - colmena — similar but with parallel deployment and tagging
   Especially important for servers (yggdrasil, alexandria) where you
   may want remote deploys.

3. No Backup Strategy (for configs/state)
   ZFS auto-scrub/snapshot on alexandria is great for NAS data, but
   missing:
   - Offsite/remote backup for critical ZFS datasets (e.g. syncoid to
     a remote target)
   - Backup for service state (Kavita database, Ollama models, etc.)
   - Disaster recovery documentation — what if alexandria dies?


Security Improvements
---------------------

4. Firewall is Too Open
   - NFS port 2049 is open on *all* hosts via the shared networking
     module, but only alexandria runs the NFS server. Scope firewall
     rules per-host.
   - Open-WebUI (8080) and Glances web interfaces are exposed without
     authentication consideration. Consider putting them behind a
     reverse proxy (Caddy/nginx) with auth.

5. No Intrusion Detection / Monitoring Alerts
   - ClamAV is good for malware scanning, but missing:
     - fail2ban for SSH brute-force protection
     - Centralized logging (Loki, Promtail, or even just forwarding
       journald)
     - Alerting when services go down (Uptime Kuma, Grafana alerts)
   - Glances is view-only monitoring — consider Prometheus + Grafana
     for historical metrics and alerting.

6. Hardcoded IPs in networking.nix
   Static IPs are fine, but they're defined in one shared module. If
   you add/remove hosts, you edit a shared file. Consider making this
   data-driven from a single source of truth (e.g. a hosts attrset in
   constants.nix).


Structural / Nix Best Practices
-------------------------------

7. No nixos-test Integration Tests
   Great linting (nixfmt, statix, deadnix) but no NixOS VM tests. For
   a homelab, even basic smoke tests are valuable:
   - Does the NFS mount config resolve correctly?
   - Does the firewall allow/block the expected ports?
   - Do services start successfully?

8. No Impermanence / Persistent State Tracking
   Consider the impermanence module to explicitly declare what state
   persists across reboots. This makes it trivial to rebuild a machine
   from scratch because you know exactly what's stateful.

9. stateVersion = "23.05" Everywhere
   This is fine (it's not meant to be bumped), but worth noting that
   machines have been running since 23.05 — just make sure any state
   migration notes for major jumps have been reviewed.

10. No disko for Declarative Disk Partitioning
    The alexandria ZFS setup and LUKS configs are in
    hardware-configuration.nix (likely auto-generated). Using disko
    would make disk layouts reproducible and documented in Nix, which
    is critical for disaster recovery.


Operations & Maintenance
------------------------

11. No Automatic Updates / Flake Lock Bumping
    Consider:
    - A GitHub Action or cron to auto-bump flake.lock weekly and open
      a PR
    - Or use renovate/dependabot for flake input updates
    - This prevents falling months behind on security patches

12. No Health Checks for Docker Services
    Kavita runs via Docker (virtualisation.oci-containers) but there
    are no health checks or restart policies beyond Docker defaults.
    Define explicit health checks and consider using NixOS-native
    services where possible instead of Docker containers.

13. No Reverse Proxy / TLS
    Services like Open-WebUI, Glances, and Kavita are exposed on raw
    ports. A reverse proxy (Caddy is popular in NixOS homelab setups)
    would give you:
    - TLS with auto-certificates (even self-signed or via Let's
      Encrypt with local DNS)
    - Single-point auth (basic auth, Authelia, etc.)
    - Clean URLs instead of ip:port

14. No DNS Resolution
    Using raw IPs everywhere (10.69.8.x). Consider running a local DNS
    server (CoreDNS, Blocky, or AdGuard Home) so you can use hostnames
    like alexandria.lan instead of 10.69.8.4.


Summary Priority List
---------------------

HIGH PRIORITY:
- [x] ~~Add sops-nix for secrets management          (Medium effort)~~ `COMPLETED: 2026-02-21 23:19:58`
- [x] ~~Add fail2ban                                  (Low effort)~~ `COMPLETED: 2026-02-21 21:05:35`
- [x] ~~Scope firewall rules per-host                 (Low effort)~~ `COMPLETED: 2026-02-21 21:15:27`

MEDIUM PRIORITY:
- [ ] Add deploy-rs/colmena for remote deployments  (Medium effort)
- [ ] Add reverse proxy (Caddy) + auth              (Medium effort)
- [ ] Add offsite backup for ZFS (syncoid)          (Medium effort)
- [x] ~~Local DNS server                              (Low effort)~~ `COMPLETED: 2026-02-22 23:36:17`
- [ ] Auto flake lock updates in CI                 (Low effort)

LOW PRIORITY:
- [ ] Add disko for declarative partitioning        (High effort)
- [x] ~~Add NixOS VM tests                            (Medium effort)~~ `COMPLETED: 2026-02-21 22:43:27`
- [ ] Add impermanence module                       (High effort)
- [x] ~~Centralized logging + alerting                (Medium effort)~~ `COMPLETED: 2026-02-22 23:36:11`
- [x] ~~Add Prometheus + Grafana~~ `COMPLETED: 2026-02-22 23:36:02`
- [x] ~~Get blocky running with Grafana~~ `COMPLETED: 2026-02-22 23:36:00`


  - Jellyfin — self-hosted Netflix for your own media (movies, TV, music). Free alternative to Plex.                                                      
  - Immich — Google Photos replacement. Auto-uploads from your phone, face recognition, search.
  - Paperless-ngx — scans, OCRs, and organizes all your documents. Tag and search PDFs.                                                                   
  - Actual Budget — self-hosted budgeting app (YNAB alternative).
  - Vaultwarden — self-hosted Bitwarden password manager.
  - Mealie — recipe manager and meal planner. Import recipes from URLs.
  - Stirling PDF — all-in-one PDF toolkit (merge, split, convert, OCR).
  - Miniflux — minimalist RSS reader.
  - Navidrome — self-hosted Spotify-like music streaming.
  - Linkding — bookmark manager (Pocket/Raindrop alternative).
  - IT-Tools — collection of handy developer tools (JSON formatter, hash generator, etc.) in a web UI.

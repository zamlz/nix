Homelab TODO
============

Infrastructure
--------------

- [ ] Add reverse proxy (Caddy) + auth              (Medium effort)
      Services are exposed on raw ports. Caddy would provide TLS,
      clean URLs (grafana.lan instead of ip:port), and single-point
      auth (basic auth, Authelia, etc.).

- [ ] Add offsite backup for ZFS (syncoid)          (Medium effort)
      Alexandria has local ZFS snapshots but no offsite copy.
      Need syncoid to a remote target, plus backup for service
      state (Kavita database, Ollama models, etc.) and disaster
      recovery documentation.

- [ ] Auto flake lock updates in CI                 (Low effort)
      GitHub Action or cron to auto-bump flake.lock weekly and
      open a PR, preventing falling behind on security patches.

- [ ] Add disko for declarative partitioning        (High effort)
      The alexandria ZFS setup and LUKS configs are in
      hardware-configuration.nix. Disko would make disk layouts
      reproducible and documented in Nix.

- [ ] Add impermanence module                       (High effort)
      Explicitly declare what state persists across reboots.
      Makes it trivial to rebuild a machine from scratch.


Services to Consider
--------------------

- Immich — Google Photos replacement. Auto-uploads from phone, face recognition, search.
- Paperless-ngx — scans, OCRs, and organizes documents. Tag and search PDFs.
- Actual Budget — self-hosted budgeting app (YNAB alternative).
- Vaultwarden — self-hosted Bitwarden password manager.
- Mealie — recipe manager and meal planner. Import recipes from URLs.
- Stirling PDF — all-in-one PDF toolkit (merge, split, convert, OCR).
- Miniflux — minimalist RSS reader.
- Navidrome — self-hosted Spotify-like music streaming.
- Linkding — bookmark manager (Pocket/Raindrop alternative).
- IT-Tools — collection of developer tools (JSON formatter, hash generator, etc.) in a web UI.


Completed
---------

- [x] Add sops-nix for secrets management          `2026-02-21`
- [x] Add fail2ban                                  `2026-02-21`
- [x] Scope firewall rules per-host                 `2026-02-21`
- [x] Add NixOS VM tests                            `2026-02-21`
- [x] Local DNS server (Blocky)                     `2026-02-22`
- [x] Centralized logging + alerting                `2026-02-22`
- [x] Add Prometheus + Grafana                      `2026-02-22`
- [x] Blocky Grafana integration                    `2026-02-22`
- [x] Jellyfin media server                         `2026-02-23`
- [x] Kavita book reader                            `2026-02-22`
- [x] Centralize constants (IPs, ports, roles)      `2026-02-24`
- [x] SSH hardening + dedicated module              `2026-02-23`
- [x] Homepage dashboard                            `2026-02-22`
- [x] Tailscale VPN mesh + subnet router             `2026-02-24`

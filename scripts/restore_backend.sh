#!/usr/bin/env bash
set -euo pipefail

# restore_backend.sh
# Diagnose- und Wiederherstellungs-Skript für das verschobene Backend-Container-Setup.
# Default: nur Diagnose sammeln und in /tmp/restore_logs schreiben.
# Mit --restore wird versucht, vorhandene docker-compose Files zu starten und Backups zu laden.

OUTDIR="/tmp/restore_logs_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"

echo "=== Phoenix Backend Restore Script ==="
echo "Logs / Outputs werden nach: $OUTDIR geschrieben"

auto_restore=false
if [[ ${1:-} == "--restore" ]]; then
  auto_restore=true
fi

log() {
  echo "[$(date +"%F %T")] $*" | tee -a "$OUTDIR/restore.log"
}

run_and_save() {
  local cmd="$*"
  log "+ $cmd"
  if $AUTO_NOP; then
    echo "(noop) $cmd" >> "$OUTDIR/commands.log"
  else
    eval "$cmd" >> "$OUTDIR/commands.out" 2>&1 || true
  fi
}

log "Start Diagnosen"

# System info
log "uname -a:"
uname -a | tee -a "$OUTDIR/system_uname.txt"

log "whoami & id:"
whoami | tee -a "$OUTDIR/whoami.txt"
id | tee -a "$OUTDIR/id.txt"

# Detect runtimes
if command -v docker >/dev/null 2>&1; then
  log "Docker erkannt"
  docker version 2>/dev/null | tee -a "$OUTDIR/docker_version.txt" || true
  log "docker ps -a"
  docker ps -a --no-trunc | tee -a "$OUTDIR/docker_ps_all.txt" || true
  log "docker images"
  docker images | tee -a "$OUTDIR/docker_images.txt" || true
  log "docker volumes"
  docker volume ls | tee -a "$OUTDIR/docker_volumes.txt" || true
  log "docker-compose (falls verfügbar)"
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose --version | tee -a "$OUTDIR/docker_compose_version.txt" || true
  elif docker compose version >/dev/null 2>&1; then
    docker compose version | tee -a "$OUTDIR/docker_compose_plugin_version.txt" || true
  fi
  log "Suche nach docker-compose.yml (maxdepth 4)"
  sudo find / -maxdepth 4 -type f -name 'docker-compose.yml' -o -name 'docker-compose.yaml' 2>/dev/null | tee -a "$OUTDIR/docker_compose_search.txt" || true
  log "Inhalt von /var/lib/docker/containers (falls vorhanden)"
  sudo ls -la /var/lib/docker/containers 2>/dev/null | tee -a "$OUTDIR/docker_containers_dir.txt" || true
fi

if command -v podman >/dev/null 2>&1; then
  log "Podman erkannt"
  podman ps -a --no-trunc | tee -a "$OUTDIR/podman_ps_all.txt" || true
  podman images | tee -a "$OUTDIR/podman_images.txt" || true
fi

if command -v lxc-ls >/dev/null 2>&1 || command -v lxc >/dev/null 2>&1; then
  log "LXC/LXD erkannt"
  if command -v lxc-ls >/dev/null 2>&1; then
    lxc-ls --fancy | tee -a "$OUTDIR/lxc_ls.txt" || true
  fi
  if command -v lxc >/dev/null 2>&1; then
    lxc list --format=json 2>/dev/null | tee -a "$OUTDIR/lxc_list.json" || true
  fi
fi

# Check postgres data directories
log "Prüfe mögliche Postgres-Datenverzeichnisse"
for p in /var/lib/postgresql /var/lib/postgresql/data /var/lib/postgresql/12 /var/lib/postgresql/13 /var/lib/postgresql/14; do
  if [ -d "$p" ]; then
    log "Found: $p"
    sudo ls -la "$p" | tee -a "$OUTDIR/postgres_dirs.txt" || true
  fi
done

# Search for likely backup files (images, tarballs)
log "Suche nach docker image backups (.tar) in typischen Pfaden"
for base in /backups /mnt /media /var/backups /home; do
  sudo find "$base" -maxdepth 3 -type f \( -iname '*.tar' -o -iname '*docker*.tar' -o -iname '*image*.tar' \) 2>/dev/null | tee -a "$OUTDIR/backup_tar_search.txt" || true
done

# Search for project docker-compose files in repository
log "Suche nach projektbezogenen compose/dateien"
sudo find / -maxdepth 6 -type f -name 'docker-compose.yml' -o -name 'docker-compose.yaml' 2>/dev/null | tee -a "$OUTDIR/compose_locations_all.txt" || true

# If manifest and content exist in current repository tree, show them
if [ -f manifest.json ]; then
  log "manifest.json gefunden im aktuellen Pfad"
  jq . manifest.json > "$OUTDIR/manifest.json.pretty" 2>/dev/null || cp manifest.json "$OUTDIR/manifest.json" || true
fi

# Summarize recommendations into a file
cat > "$OUTDIR/RECOMMENDATIONS.txt" <<'EOF'
Diagnose abgeschlossen. Empfohlene nächste Schritte:

1) Falls docker-compose.yml in einem bekannten Projektpfad gefunden wurde:
   - cd <pfad>
   - sudo docker-compose up -d
   - docker ps -a

2) Falls ein backup-*.tar gefunden wurde:
   - sudo docker load -i /pfad/zum/backup.tar
   - docker images
   - docker run -d --name phoenix-restored -p 3000:3000 <image:tag>

3) Falls Postgres-Daten verschoben sind, kopieren Sie sie zurück nach /var/lib/postgresql und achten Sie auf Eigentümer postgres:postgres
   - sudo rsync -a /pfad/backup_pgdata/ /var/lib/postgresql/
   - sudo chown -R postgres:postgres /var/lib/postgresql
   - sudo systemctl restart postgresql

4) Falls nichts auffindbar ist: bauen wir das Backend neu aus Quellcode (im repository/ backend/)
   - docker build -t emergencese-droid/phoenix-backend:local ./backend
   - docker run -d --name phoenix-temp -p 3000:3000 -e DATABASE_URL='postgresql://postgres:postgres@db:5432/phoenix' emergencese-droid/phoenix-backend:local

5) Teilen Sie die Logs in $OUTDIR mit dem Dev-Team oder in dieses Chatfenster.

EOF

log "Diagnose fertig. Dateien:"
ls -la "$OUTDIR" | tee -a "$OUTDIR/dir_listing.txt"

# If user requested auto-restore, attempt non-destructive restores
if [ "$auto_restore" = true ]; then
  log "--restore gesetzt: Versuche automatisch vorhandene docker-compose Dateien zu starten (wenn gefunden)"
  mapfile -t paths < <(sudo find / -maxdepth 6 -type f -name 'docker-compose.yml' -o -name 'docker-compose.yaml' 2>/dev/null || true)
  for p in "${paths[@]}"; do
    dir=$(dirname "$p")
    log "Versuche docker-compose im Verzeichnis: $dir"
    (cd "$dir" && sudo docker-compose pull 2>/dev/null || true)
    (cd "$dir" && sudo docker-compose up -d) || log "docker-compose up fehlgeschlagen im $dir"
  done

  # If no postgres container is running, start a temporary one
  if ! docker ps --format '{{.Names}}' | grep -q -E "postgres|pg|db"; then
    log "Keine Postgres-Container gefunden — starte temporäre postgres-Instanz 'pg-temp'"
    if docker ps -a --format '{{.Names}}' | grep -q '^pg-temp$'; then
      docker start pg-temp || true
    else
      docker run -d --name pg-temp -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=phoenix postgres:15 || true
    fi
  else
    log "Postgres-Container vorhanden — überspringe temporäres Starten"
  fi

  # Try to start a backend if an image named emergencese-droid/phoenix-backend exists
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^emergencese-droid/phoenix-backend'; then
    img=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '^emergencese-droid/phoenix-backend' | head -n1)
    if docker ps -a --format '{{.Names}}' | grep -q '^phoenix-temp$'; then
      docker start phoenix-temp || true
    else
      docker run -d --name phoenix-temp -p 3000:3000 -e DATABASE_URL='postgresql://postgres:postgres@pg-temp:5432/phoenix' "$img" || true
    fi
  fi

  log "Auto-Restore abgeschlossen. Prüfen Sie 'docker ps -a' und die Logs in $OUTDIR"
fi

log "Skriptende. Bitte teilen Sie den Inhalt von $OUTDIR (tar.gz) mit dem Support / im Chat wenn weitere Hilfe benötigt wird."

echo "Erzeuge Archiv der Logs..."
tar czf "$OUTDIR.tar.gz" -C "$(dirname "$OUTDIR")" "$(basename "$OUTDIR")" || true
log "Archiv: $OUTDIR.tar.gz"

exit 0

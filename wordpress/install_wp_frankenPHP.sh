#!/bin/bash

set -e

# =========================================================
# Production-Ready WordPress Installer with FrankenPHP
# - Installs WordPress core and configurations via WP-CLI
# - Automatically detects and installs FrankenPHP if missing
# - Fixed: Removed invalid --skip-check from wp core install
# =========================================================

prompt_var () {
  local __var_name="$1"
  local __prompt="$2"
  local __default="$3"
  local __secret="${4:-0}"
  local __current_val="${!__var_name}"
  local __input=""

  if [ "${SKIP_PROMPTS:-0}" = "1" ] || [ -n "$__current_val" ]; then
    if [ -z "$__current_val" ] && [ -n "$__default" ]; then
      eval "$__var_name=\"\$__default\""
    fi
    return
  fi

  if [ "$__secret" = "1" ]; then
    read -r -s -p "$__prompt [$__default]: " __input
    echo
  else
    read -r -p "$__prompt [$__default]: " __input
  fi

  if [ -z "$__input" ]; then
    __input="$__default"
  fi

  eval "$__var_name=\"\$__input\""
}

is_yes() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    y|yes|1|true) return 0 ;;
    *) return 1 ;;
  esac
}

echo "🚀 WordPress & FrankenPHP Automated Deployment Setup"

# ---------- DB Configuration ----------
prompt_var DB_NAME        "Database name"       "wp_franken_db"
prompt_var DB_USER        "Database user"       "root"
prompt_var DB_PASS        "Database password"   "admin123" 1
prompt_var DB_HOST        "Database host"       "127.0.0.1"

# ---------- WordPress Configuration ----------
prompt_var WP_URL         "Site URL / Domain"   "http://localhost:8080"
prompt_var WP_TITLE       "Site title"          "My FrankenPHP WordPress Site"
prompt_var WP_ADMIN_USER  "WP admin username"   "admin"
prompt_var WP_ADMIN_PASS  "WP admin password"   "Admin123$" 1
prompt_var WP_ADMIN_EMAIL "WP admin email"      "admin@example.com"

# ---------- Installation Paths ----------
prompt_var WP_PATH        "WordPress path"      "/var/www/html/wordpress"
prompt_var FRANKEN_PORT   "FrankenPHP Port"     "8080"
prompt_var ENABLE_HTTPS   "Enable production HTTPS? yes/no" "no"

echo
echo "📋 Configuration Summary:"
echo "  DB_NAME=$DB_NAME"
echo "  DB_USER=$DB_USER"
echo "  DB_HOST=$DB_HOST"
echo "  WP_URL=$WP_URL"
echo "  WP_TITLE=$WP_TITLE"
echo "  WP_PATH=$WP_PATH"
echo "  FRANKEN_PORT=$FRANKEN_PORT"
echo "  ENABLE_HTTPS=$ENABLE_HTTPS"
echo

# ---------- SUDO Privilege Helper ----------
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
  export WP_CLI_ALLOW_ROOT=1
else
  SUDO="sudo"
fi

# ---------- Fallback Package Installer ----------
install_pkgs() {
  if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update -y
    $SUDO apt-get install -y "$@"
  elif command -v dnf >/dev/null 2>&1; then
    $SUDO dnf install -y "$@"
  elif command -v yum >/dev/null 2>&1; then
    $SUDO yum install -y "$@"
  elif command -v apk >/dev/null 2>&1; then
    $SUDO apk add --no-cache "$@"
  else
    echo "❌ System package manager not identified. Install dependencies manually."
    exit 1
  fi
}

# ---------- Parse Domain Host from URL ----------
get_wp_host() {
  echo "$WP_URL" | sed -E 's~^[a-zA-Z]+://~~; s~/.*$~~; s~:.*$~~'
}

# ---------- Update local /etc/hosts for custom domains ----------
update_hosts_file() {
  local host="$1"
  if [ -z "$host" ] || [ "$host" = "localhost" ] || [ "$host" = "127.0.0.1" ]; then
    return
  fi
  if echo "$host" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    return
  fi

  HOSTS_FILE="/etc/hosts"
  if grep -Eq "^[[:space:]]*127\.0\.0\.1[[:space:]].*\b${host}\b" "$HOSTS_FILE"; then
    return
  fi

  echo "🧾 Adding temporary local domain mapping: 127.0.0.1 $host"
  if [ -n "$($SUDO tail -c1 "$HOSTS_FILE" 2>/dev/null)" ]; then
    $SUDO sh -c "printf '\n' >> '$HOSTS_FILE'"
  fi
  $SUDO sh -c "printf '127.0.0.1\t%s\n' '$host' >> '$HOSTS_FILE'"
}

# ---------- Ensure WP-CLI Availability ----------
ensure_wp_cli() {
  if command -v wp >/dev/null 2>&1; then
    echo "✅ WP-CLI is already available: $(command -v wp)"
    return
  fi

  echo "⬇️ WP-CLI not found. Commencing automated installation..."
  command -v php >/dev/null 2>&1 || install_pkgs php-cli php-mysql || install_pkgs php
  command -v curl >/dev/null 2>&1 || install_pkgs curl

  local tmp="/tmp/wp-cli.phar"
  curl -sSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o "$tmp" || {
    echo "❌ Failed to download WP-CLI bin distribution."
    exit 1
  }

  chmod +x "$tmp"
  if $SUDO mv "$tmp" /usr/local/bin/wp 2>/dev/null; then
    echo "✅ WP-CLI successfully placed globally into /usr/local/bin/wp"
  else
    mkdir -p "$HOME/.local/bin"
    mv "$tmp" "$HOME/.local/bin/wp"
    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ WP-CLI installed into local user path space: $HOME/.local/bin/wp"
  fi
}

# ---------- Ensure FrankenPHP Binary Engine ----------
ensure_frankenphp() {
  if command -v frankenphp >/dev/null 2>&1; then
    echo "✅ FrankenPHP app server engine found: $(command -v frankenphp)"
    return
  fi

  echo "⬇️ FrankenPHP absent. Executing self-contained static runtime recovery installation..."
  command -v curl >/dev/null 2>&1 || install_pkgs curl

  local tmp_bin="/tmp/frankenphp"
  
  # Fetch via official distribution installer script line
  curl -sS https://frankenphp.dev/install.sh | sh || true
  
  if [ -f "./frankenphp" ]; then
    mv ./frankenphp "$tmp_bin"
  fi

  # Fallback to direct download via GitHub releases if script asset retrieval fails
  if [ ! -f "$tmp_bin" ]; then
    echo "⚠️ Upstream installer script failed, initializing architecture-targeted fallback..."
    local arch
    arch=$(uname -m)
    if [ "$arch" = x86_64 ]; then arch="linux-x86_64"; else arch="linux-aarch64"; fi
    curl -sSL "https://github.com/dunglas/frankenphp/releases/latest/download/frankenphp-$arch" -o "$tmp_bin"
  fi

  if [ ! -f "$tmp_bin" ]; then
    echo "❌ Execution failure: Unable to safely download a workable static FrankenPHP binary."
    exit 1
  fi

  chmod +x "$tmp_bin"
  $SUDO mv "$tmp_bin" /usr/local/bin/frankenphp
  echo "✅ FrankenPHP server engine deployed to /usr/local/bin/frankenphp"
}

# ---------- Execution Flow Orchestration ----------
ensure_wp_cli
ensure_frankenphp

echo "📁 Structuring persistent environment and layout directories..."
$SUDO mkdir -p "$WP_PATH"
$SUDO mkdir -p /etc/frankenphp /var/log/frankenphp /etc/frankenphp/conf.d

if [ "$(id -u)" -ne 0 ]; then
  $SUDO chown -R "$USER:$USER" "$WP_PATH"
fi

cd "$WP_PATH" || exit 1

# ---------- Database Provisioning Check ----------
echo "🛢️ Verifying relational system database existence..."
if command -v mysql >/dev/null 2>&1; then
  mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -e "
  CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
  " || echo "⚠️ Auto DB provisioning failed; continuing assuming schema access permissions exist."
else
  echo "ℹ️ Local mysql client binary not found to pre-create database. WP-CLI will attempt initialization."
fi

# ---------- WordPress Asset Download Handling ----------
if [ ! -f "$WP_PATH/wp-load.php" ]; then
  echo "⬇️ Pulling verified WordPress production bundle..."
  wp core download --path="$WP_PATH" --allow-root
fi

# ---------- Automated System wp-config.php Building ----------
if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "⚙️ Engineering optimized configuration matrix parameters..."
  wp config create \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASS" \
    --dbhost="$DB_HOST" \
    --path="$WP_PATH" \
    --skip-check \
    --allow-root
fi

# ---------- Complete Zero-Touch Core Deployment Routine ----------
if ! wp core is-installed --path="$WP_PATH" --allow-root 2>/dev/null; then
  echo "📝 Provisioning metadata entities and global user configurations..."
  wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --path="$WP_PATH" \
    --allow-root
fi

echo "🔗 Writing core router rules..."
wp rewrite structure '/%postname%/' --path="$WP_PATH" --allow-root
wp rewrite flush --hard --path="$WP_PATH" --allow-root || true

# ---------- Generate Official FrankenPHP Caddyfile Config ----------
echo "🛠️ Creating optimized, low-latency production Caddyfile..."
WP_DOMAIN=$(get_wp_host)
update_hosts_file "$WP_DOMAIN"

# If HTTPS is enabled, ensure WP_URL uses https scheme
if is_yes "$ENABLE_HTTPS"; then
  WP_URL=$(echo "$WP_URL" | sed 's~^http://~https://~')
  # Update wp-config with the corrected URL
  wp option update siteurl "$WP_URL" --path="$WP_PATH" --allow-root 2>/dev/null || true
  wp option update home    "$WP_URL" --path="$WP_PATH" --allow-root 2>/dev/null || true
fi

if is_yes "$ENABLE_HTTPS"; then
  BIND_TARGET="${WP_DOMAIN}"
else
  BIND_TARGET=":${FRANKEN_PORT}"
fi

$SUDO tee /etc/frankenphp/Caddyfile > /dev/null <<EOF
{
    frankenphp
    order php_server before file_server
}

${BIND_TARGET} {
    root * ${WP_PATH}
    
    # Enable the native FrankenPHP execution handler
    php_server

    # Modern compression capabilities
    encode zstd gzip

    # Unified server logging rules
    log {
        output file /var/log/frankenphp/access.log
    }

    # Production infrastructure hardening headers
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options SAMEORIGIN
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }
}
EOF

# ---------- Automated Systemd Service Integration ----------
echo "🤖 Registering FrankenPHP daemon instance inside process lifecycle managers..."
$SUDO tee /etc/systemd/system/frankenphp.service > /dev/null <<EOF
[Unit]
Description=FrankenPHP Production Application Server for WordPress
After=network.target network-online.target mysql.service mariadb.service
Wants=network-online.target

[Service]
Type=exec
ExecStart=/usr/local/bin/frankenphp run --config /etc/frankenphp/Caddyfile
WorkingDirectory=${WP_PATH}
User=www-data
Group=www-data
# Grant port-binding capability so www-data can listen on 80/443 without running as root
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
Restart=always
RestartSec=3s

# Runtime execution and tuning context vars
Environment=PHP_INI_SCAN_DIR=/etc/frankenphp/conf.d
Environment=XDG_DATA_HOME=/var/lib/frankenphp/data
Environment=XDG_CONFIG_HOME=/var/lib/frankenphp/config

[Install]
WantedBy=multi-user.target
EOF

# ---------- Optimized Standalone Engine PHP Configs ----------
$SUDO tee /etc/frankenphp/conf.d/wordpress-tuning.ini > /dev/null <<EOF
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 128M
post_max_size = 128M

; Hardened Production OPcache variables
opcache.enable = 1
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 15000
opcache.memory_consumption = 256
opcache.save_comments = 1
opcache.validate_timestamps = 0
EOF

# ---------- Strict Asset Access Control Level Mappings ----------
echo "🔐 Aligning file system access control lists (ACL) ownership maps..."
WEB_USER="www-data"
$SUDO mkdir -p /var/lib/frankenphp /var/lib/frankenphp/data /var/lib/frankenphp/config

$SUDO chown -R "$WEB_USER:$WEB_USER" "$WP_PATH" /var/log/frankenphp /etc/frankenphp /var/lib/frankenphp
$SUDO find "$WP_PATH" -type d -exec chmod 755 {} \;
$SUDO find "$WP_PATH" -type f -exec chmod 644 {} \;
$SUDO chmod 640 "$WP_PATH/wp-config.php" 2>/dev/null || true

# ---------- Service Lifecycle Invocation and Legacy Conflicts Removal ----------
echo "🔄 Managing system socket conflicts and executing process deployment..."
$SUDO systemctl stop apache2 nginx httpd 2>/dev/null || true
$SUDO systemctl disable apache2 nginx httpd 2>/dev/null || true

$SUDO systemctl daemon-reload
$SUDO systemctl enable frankenphp
$SUDO systemctl restart frankenphp

# ---------- Comprehensive Multi-point Verification Health Checks ----------
echo "🧪 Invoking health monitoring verification checklist..."
sleep 3

# 1. Daemon Engine Check
if ! systemctl is-active --quiet frankenphp; then
  echo "❌ Critical failure: FrankenPHP service unit could not be brought online safely."
  echo "📄 Fetching current error trace details via journalctl:"
  $SUDO journalctl -u frankenphp --no-pager -n 20
  exit 1
fi

# 2. Local Endpoint Network Loopback Query Check
if command -v curl >/dev/null 2>&1; then
  CHECK_URL="http://127.0.0.1:${FRANKEN_PORT}"
  if is_yes "$ENABLE_HTTPS"; then
    CHECK_URL="https://${WP_DOMAIN}"
  fi
  
  echo "🌐 Verifying loopback connectivity target via request ($CHECK_URL)..."
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" --insecure "$CHECK_URL" || echo "000")
  if [ "$STATUS_CODE" -ge 200 ] && [ "$STATUS_CODE" -lt 400 ]; then
    echo "✅ Application endpoint successfully responded with healthy status code: $STATUS_CODE"
  else
    echo "⚠️ Alert: Received unexpected response status ($STATUS_CODE). Verify routing paths."
  fi
fi

# ---------- Cache Layer Flushing and Termination ----------
wp cache flush --path="$WP_PATH" --allow-root || true

echo
echo "🎉 WordPress application server migration to FrankenPHP completed successfully!"
echo "🌐 Destination URL Path: $WP_URL"
echo "👤 Management Identity: $WP_ADMIN_USER"
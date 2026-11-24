#!/usr/bin/env bash

set -euo pipefail

# Fallback values if repository secrets are not provided (e.g. fork builds)
if [[ -z "${LOCAL_PROPERTIES_BASE64:-}" ]]; then
    echo "LOCAL_PROPERTIES_BASE64 not set, creating dummy local.properties for fork build"
    cat << 'EOF' > local.properties
NUVIO_SUPABASE_URL=https://dummy.supabase.co
NUVIO_SUPABASE_ANON_KEY=dummy-anon-key
TRAKT_CLIENT_ID=dummy-trakt-id
TRAKT_CLIENT_SECRET=dummy-trakt-secret
EOF
else
    printf '%s' "${LOCAL_PROPERTIES_BASE64}" | base64 --decode > local.properties
    sed -i -E '/^[[:space:]]*(sdk\.dir|NUVIO_RELEASE_(STORE_FILE|STORE_PASSWORD|KEY_ALIAS|KEY_PASSWORD)|NUVIO_MACOS_(SIGNING_IDENTITY|NOTARY_APPLE_ID|NOTARY_TEAM_ID|NOTARY_PASSWORD|NOTARY_KEYCHAIN_PROFILE|NOTARY_KEYCHAIN_PATH))[[:space:]]*=/d' local.properties
fi

if [[ -z "${SENTRY_DESKTOP_DSN:-}" ]]; then
    export SENTRY_DESKTOP_DSN="https://dummy@dummy.ingest.sentry.io/0"
fi

required_properties=(
    NUVIO_SUPABASE_URL
    NUVIO_SUPABASE_ANON_KEY
    TRAKT_CLIENT_ID
    TRAKT_CLIENT_SECRET
)
for property_name in "${required_properties[@]}"; do
    if ! grep -Eq "^${property_name}=.+" local.properties; then
        echo "Missing required desktop property: ${property_name}" >&2
        exit 1
    fi
done

echo "Desktop runtime configuration completed successfully."

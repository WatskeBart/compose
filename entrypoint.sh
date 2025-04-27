#!/usr/bin/env bash
set -Eeo pipefail

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		printf >&2 'error: both %s and %s are set (but are exclusive)\n' "$var" "$fileVar"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}


_main() {
    file_env 'KC_BOOTSTRAP_ADMIN_USERNAME'
    file_env 'KC_BOOTSTRAP_ADMIN_PASSWORD'
    file_env 'KC_DB_USERNAME'
    file_env 'KC_DB_PASSWORD'
    file_env 'KC_DB_URL_DATABASE'
	exec /opt/keycloak/bin/kc.sh "$@"
}

_main "$@"
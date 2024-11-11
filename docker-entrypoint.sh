#!/bin/bash
set -e

if [[ "$1" == "particl-cli" || "$1" == "particl-tx" || "$1" == "particld" || "$1" == "test_particl" ]]; then
	mkdir -p "$PARTICL_DATA"

	CONFIG_PREFIX=""
	if [[ "${PARTICL_NETWORK}" == "regtest" ]]; then
		CONFIG_PREFIX=$'regtest=1\n[regtest]'
	fi
	if [[ "${PARTICL_NETWORK}" == "testnet" ]]; then
		CONFIG_PREFIX=$'testnet=1\n[test]'
	fi
	if [[ "${PARTICL_NETWORK}" == "mainnet" ]]; then
		CONFIG_PREFIX=$'mainnet=1\n[main]'
	fi

	cat <<-EOF > "$PARTICL_DATA/particl.conf"
	${CONFIG_PREFIX}
	printtoconsole=1
	rpcallowip=::/0
	${PARTICL_EXTRA_ARGS}
	EOF
	chown particl:particl "$PARTICL_DATA/particl.conf"

	# ensure correct ownership and linking of data directory
	# we do not update group ownership here, in case users want to mount
	# a host directory and still retain access to it
	chown -R particl "$PARTICL_DATA"
	ln -sfn "$PARTICL_DATA" /home/particl/.particl
	chown -h particl:particl /home/particl/.particl

	exec gosu particl "$@"
else
	exec "$@"
fi

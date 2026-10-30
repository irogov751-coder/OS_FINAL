#!/bin/bash
CONFIG_FILE="server.conf"
>"$CONFIG_FILE"
VARS=("SERVER_NAME" "MAX_PLAYERS" "SPAWN_COORDS")
DEFAULTS=("StarCraft" "125" "274 67 -249")
for i in "${!VARS[@]}"; do
	VAR_NAME="${VARS[$i]}"
	DEFAULT_NAME="${DEFAULTS[$i]}"
	CURRENT_VAR="${!VAR_NAME}"
	if [ -z "$CURRENT_VAR" ]; then     #-z check empty line
		final_val="$DEFAULT_NAME"
	else
		final_val="$CURRENT_VAR"
	fi
	echo ${VAR_NAME}=\"${final_val}\" >> "$CONFIG_FILE"
done

cat "$CONFIG_FILE"	

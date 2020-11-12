#!/bin/bash

function usage() {
        (
        echo "usage: $0 <auth-token> <group-address> <mbox-dir>"
        echo "To generate an auth token go to https://developers.google.com/oauthplayground/ and get an access token for Google Groups migration"
        ) >&2
        exit 5
}

AUTH_TOKEN="$1"
shift
GROUP="$1"
shift
MBOX_DIR="$1"
shift

[ -z "$AUTH_TOKEN" -o -z "$GROUP" -o -z "$MBOX_DIR" ] && usage

SUCCESS="$MBOX_DIR/successful"

mkdir -p $SUCCESS

success_count=0
failure_count=0

for file in $MBOX_DIR/*.eml; do
	if curl --fail -H"Authorization: Bearer $AUTH_TOKEN" -H'Content-Type: message/rfc822' -X POST "https://www.googleapis.com/upload/groups/v1/groups/$GROUP/archive?uploadType=media" --data-binary "@$file"; then  
		mv "$file" $SUCCESS
		success_count=$((success_count + 1))
		echo "Unit ok: $success_count"
	else
		failure_count=$((failure_count + 1))
		echo "Unit: $failure_count"
		exit

	fi
done

echo "Done. $success_count successfully imported, $failure_count failed."

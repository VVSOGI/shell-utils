#!/bin/bash

ACCESS_TOKEN=$1
LABELS_FILE=$2
REPOSITORY=$3
DRY_RUN=$4
ALLOW_ADDED_LABELS=$5

if [ -z "$ACCESS_TOKEN" ] || [ -z "$LABELS_FILE" ] || [ -z "$REPOSITORY" ]; then
    exit 1
fi

if [ ! -f "$LABELS_FILE" ]; then
    exit 1
fi

if ! jq empty "$LABELS_FILE" 2>/dev/null; then
    exit 1
fi

CURRENT_LABELS=$(curl -s -H "Authorization: token $ACCESS_TOKEN" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/$REPOSITORY/labels")

echo $CURRENT_LABELS

if [[ "$CURRENT_LABELS" == *"Not Found"* ]]; then
    exit 1
fi

if [[ "$CURRENT_LABELS" == *"Bad credentials"* ]]; then
    exit 1
fi


CURRENT_LABEL_COUNT=$(echo "$CURRENT_LABELS" | jq '. | length')
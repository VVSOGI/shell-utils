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

if [[ "$CURRENT_LABELS" == *"Not Found"* ]]; then
    exit 1
fi

if [[ "$CURRENT_LABELS" == *"Bad credentials"* ]]; then
    exit 1
fi


CURRENT_LABEL_COUNT=$(echo "$CURRENT_LABELS" | jq '. | length')
NEW_LABELS=$(cat "$LABELS_FILE")
NEW_LABEL_COUNT=$(echo "$NEW_LABELS" | jq '. | length')

for row in $(echo "${NEW_LABELS}" | jq -r '.[] | @base64'); do
    LABEL=$(echo "${row}" | base64 --decode)    
    NAME=$(echo "${LABEL}" | jq -r '.name')
    COLOR=$(echo "${LABEL}" | jq -r '.color')
    DESCRIPTION=$(echo "${LABEL}" | jq -r '.description // ""')
    EXISTING_LABEL=$(echo "${CURRENT_LABELS}" | jq -r --arg name "$NAME" '.[] | select(.name == $name)')

    if [ -n "$EXISTING_LABEL" ]; then
        echo -e "update:$NAME"
        
        if [ "$DRY_RUN" = false ]; then
            ENCODED_NAME=$(echo "$NAME" | sed 's/ /%20/g' | sed 's/#/%23/g')
            
            curl -s -X PATCH \
                -H "Authorization: token $ACCESS_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                -d "{\"name\":\"$NAME\",\"color\":\"$COLOR\",\"description\":\"$DESCRIPTION\"}" \
                "https://api.github.com/repos/$REPOSITORY/labels/$ENCODED_NAME" > /dev/null
        fi
    else
        echo "create:$NAME"
        
        if [ "$DRY_RUN" = false ]; then
            curl -s -X POST \
                -H "Authorization: token $ACCESS_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                -d "{\"name\":\"$NAME\",\"color\":\"$COLOR\",\"description\":\"$DESCRIPTION\"}" \
                "https://api.github.com/repos/$REPOSITORY/labels" > /dev/null
        fi
    fi
done

if [ "$ALLOW_ADDED_LABELS" = false ]; then
    for row in $(echo "${CURRENT_LABELS}" | jq -r '.[] | @base64'); do
        LABEL=$(echo "${row}" | base64 --decode)
        CURRENT_NAME=$(echo "${LABEL}" | jq -r '.name')
        FOUND=$(echo "${NEW_LABELS}" | jq -r --arg name "$CURRENT_NAME" '.[] | select(.name == $name) | .name')
        
        if [ -z "$FOUND" ]; then
            echo "delete:$CURRENT_NAME"
            
            if [ "$DRY_RUN" = false ]; then
                ENCODED_NAME=$(echo "$CURRENT_NAME" | sed 's/ /%20/g' | sed 's/#/%23/g')
                
                curl -s -X DELETE \
                    -H "Authorization: token $ACCESS_TOKEN" \
                    -H "Accept: application/vnd.github.v3+json" \
                    "https://api.github.com/repos/$REPOSITORY/labels/$ENCODED_NAME" > /dev/null
            fi
        fi
    done
fi

echo "done"
exit 0

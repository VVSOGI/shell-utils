#!/bin/bash

# GitHub Label
# github-label-sync [token] [json 위치] [user-name]/[repository-name]

prompt_for_input() {
  echo "Input for github-label-sync:"
  
  if [ -z "$1" ]; then
    echo -n "GitHub access token: "
    read -s ACCESS_TOKEN
    echo ""
  else
    ACCESS_TOKEN=$1
  fi
  
  if [ -z "$2" ]; then
    echo -n "Path to labels JSON file: "
    read LABELS_FILE
  else
    LABELS_FILE=$2
  fi
  
  if [ -z "$3" ]; then
    echo -n "GitHub repository (format: user/repo): "
    read REPOSITORY
  else
    REPOSITORY=$3
  fi
  
  if [ -z "$4" ]; then
    echo -n "Dry run mode? (y/n): "
    read DRY_RUN_CHOICE
    if [[ $DRY_RUN_CHOICE == [yY] ]]; then
        DRY_RUN=true
    else
        DRY_RUN=false
    fi
  else
    DRY_RUN=$4
  fi

  if [ -z "$5" ]; then
    echo -n "Do you want to keep the existing labels (y/n): "
    read KEEP_LABELS_CHOICE
    if [[ $KEEP_LABELS_CHOICE == [yY] ]]; then
        ALLOW_ADDED_LABELS=true
    else
        ALLOW_ADDED_LABELS=false
    fi
  else
    ALLOW_ADDED_LABELS=$5
  fi
}

check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo "Error: jq command not found, please install with ‘apt-get install jq’ or ‘brew install jq’"
    exit 1
  fi
  
  if ! command -v curl &> /dev/null; then
    echo "Error: The curl command was not found, please install with ‘apt-get install curl’."
    exit 1
  fi
}

main() {
  check_dependencies
  
  prompt_for_input "$1" "$2" "$3" "$4" "$5"
  
  echo ""
  echo "==================Settings Summary=================="
  echo "Access Token: [hidden]"
  echo "Label File  : $LABELS_FILE"
  echo "Repository  : $REPOSITORY"
  echo "Dry Run     : $DRY_RUN"
  echo "Keep labels : $ALLOW_ADDED_LABELS"
  echo "===================================================="
  echo
  
  echo -n "Do you want to proceed? (y/n): "
  read CONFIRM
  if [[ ! $CONFIRM == [yY] ]]; then
    echo "The synchronization has been canceled."
    exit 0
  fi
  
  echo "Starting label synchronization..."
  
  OUTPUT=$(./github-label-sync.sh "$ACCESS_TOKEN" "$LABELS_FILE" "$REPOSITORY" "$DRY_RUN" "$ALLOW_ADDED_LABELS")
  
  while IFS= read -r line; do
    if [[ "$line" == "update:"* ]]; then
      LABEL=${line#update:}
      echo "Update label: $LABEL"
    elif [[ "$line" == "create:"* ]]; then
      LABEL=${line#create:}
      echo "Create label: $LABEL"
    elif [[ "$line" == "delete:"* ]]; then
      LABEL=${line#delete:}
      echo "Delete label: $LABEL"
    elif [[ "$line" == "done" ]]; then
      echo "Label synchronization is done!"
    fi
  done <<< "$OUTPUT"
}

main "$1" "$2" "$3" "$4" "$5"
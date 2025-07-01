#!/bin/bash

# GitHub Label
# github-label-sync [token] [json 위치] [user-name]/[repository-name]

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

    LABELS_FILE="./labels.json"


prompt_for_input() {
  echo -e "${BOLD}Input for github-label-sync:${NC}"
  
  if [ -z "$1" ]; then
    echo -n -e "${CYAN}GitHub access token: ${NC}"
    read -s ACCESS_TOKEN
    echo ""
  else
    ACCESS_TOKEN=$1
  fi
  
  if [ -z "$2" ]; then
    echo -n -e "${CYAN}GitHub repository (format: 'user/repo' ${RED}NOT ALL URL LIKE 'https://github.com/VVSOGI/shell-utils'${CYAN}): ${NC}"
    read REPOSITORY
  else
    REPOSITORY=$2
  fi
  
  if [ -z "$3" ]; then
    echo -n -e "${CYAN}Dry run mode? (If you select Yes, it won't actually work.) (y/n): ${NC}"
    read DRY_RUN_CHOICE
    if [[ $DRY_RUN_CHOICE == [yY] ]]; then
        DRY_RUN=true
    else
        DRY_RUN=false
    fi
  else
    DRY_RUN=$3
  fi

  if [ -z "$4" ]; then
    echo -n -e "${CYAN}Do you want to keep the existing labels (y/n): ${NC}"
    read KEEP_LABELS_CHOICE
    if [[ $KEEP_LABELS_CHOICE == [yY] ]]; then
        ALLOW_ADDED_LABELS=true
    else
        ALLOW_ADDED_LABELS=false
    fi
  else
    ALLOW_ADDED_LABELS=$4
  fi
}

check_dependencies() {
  if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq command not found, please install with 'apt-get install jq' or 'brew install jq'${NC}"
    exit 1
  fi
  
  if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: The curl command was not found, please install with 'apt-get install curl'.${NC}"
    exit 1
  fi
}

main() {
  check_dependencies
  
  prompt_for_input "$1" "$2" "$3" "$4"
  
  echo ""
  echo -e "${BOLD}${BLUE}==================Settings Summary==================${NC}"
  echo -e "${BOLD}Access Token:${NC} [hidden]"
  echo -e "${BOLD}Label File  :${NC} ${YELLOW}$LABELS_FILE${NC}"
  echo -e "${BOLD}Repository  :${NC} ${YELLOW}$REPOSITORY${NC}"
  echo -e "${BOLD}Dry Run     :${NC} ${YELLOW}$DRY_RUN${NC}"
  echo -e "${BOLD}Keep labels :${NC} ${YELLOW}$ALLOW_ADDED_LABELS${NC}"
  echo -e "${BOLD}${BLUE}====================================================${NC}"
  echo
  
  echo -n -e "${CYAN}Do you want to proceed? (y/n): ${NC}"
  read CONFIRM
  if [[ ! $CONFIRM == [yY] ]]; then
    echo -e "${YELLOW}The synchronization has been canceled.${NC}"
    exit 0
  fi
  
  echo -e "${BLUE}Starting label synchronization...${NC}"
  
  OUTPUT=$(./github-label-sync.sh "$ACCESS_TOKEN" "$LABELS_FILE" "$REPOSITORY" "$DRY_RUN" "$ALLOW_ADDED_LABELS")
  echo $OUTPUT
  
  while IFS= read -r line; do
    if [[ "$line" == "update:"* ]]; then
      LABEL=${line#update:}
      echo -e "${YELLOW}Update label: ${BOLD}$LABEL${NC}"
    elif [[ "$line" == "create:"* ]]; then
      LABEL=${line#create:}
      echo -e "${GREEN}Create label: ${BOLD}$LABEL${NC}"
    elif [[ "$line" == "delete:"* ]]; then
      LABEL=${line#delete:}
      echo -e "${RED}Delete label: ${BOLD}$LABEL${NC}"
    elif [[ "$line" == "done" ]]; then
      echo -e "${GREEN}${BOLD}Label synchronization is done!${NC}"
    fi
  done <<< "$OUTPUT"
}

main "$1" "$2" "$3" "$4"
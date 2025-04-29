#!/bin/bash

# Define an array of secret names to create
SECRET_NAMES=("dbpassword" "dbusername" "dbname" "kcadminusername" "kcadminpassword")

# ANSI color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to read password with asterisk feedback
read_password_with_stars() {
  unset password
  local prompt="$1"
  echo -ne "${prompt}"
  
  # Turn off echoing
  stty -echo
  
  local chars=()
  
  while IFS= read -r -s -n1 char; do
    # Exit on Enter key
    if [[ $char == $'\0' || $char == $'\n' ]]; then
      echo
      break
    fi
    
    # Handle backspace/delete
    if [[ $char == $'\177' ]]; then
      if [ ${#chars[@]} -gt 0 ]; then
        unset "chars[${#chars[@]}-1]"
        # Move cursor back, erase character, move cursor back again
        echo -ne "\b \b"
      fi
    else
      chars+=("$char")
      # Print asterisk for visual feedback
      echo -ne "*"
    fi
  done
  
  # Restore terminal settings
  stty echo
  
  # Join characters into password
  password=$(printf "%s" "${chars[@]}")
}

# Function to check if podman is installed
check_podman() {
  if ! command -v podman &> /dev/null; then
    echo -e "${RED}Error: Podman is not installed or not in your PATH.${NC}"
    return 1
  fi
  return 0
}

# Function to check if a podman secret already exists
podman_secret_exists() {
  podman secret inspect "$1" &> /dev/null
  return $?
}

# Main function
create_secrets() {
  # Check for podman
  if ! check_podman; then
    echo -e "${RED}Error: Podman is not available. Please install it first.${NC}"
    exit 1
  fi
  
  # Display header
  echo -e "${BLUE}=== Podman Secrets Manager ===${NC}"
  echo -e "This script will create the following secrets:"
  for secret in "${SECRET_NAMES[@]}"; do
    echo -e "  - ${secret}"
  done
  
  echo -e "\nSecrets will be created for ${GREEN}Podman${NC}"
  echo ""
  
  # Process each secret in the array
  for secret_name in "${SECRET_NAMES[@]}"; do
    local replace_podman=false
    
    # Check if secret already exists in Podman
    if podman_secret_exists "$secret_name"; then
      echo -e "${BLUE}Podman secret '$secret_name' already exists.${NC}"
      read -p "Do you want to replace it? (y/n): " replace
      if [[ $replace =~ [yY] ]]; then
        replace_podman=true
      else
        echo -e "Skipping secret '$secret_name'..."
        continue
      fi
    fi
    
    # Prompt for secret value with asterisk feedback
    read_password_with_stars "${BLUE}Enter value for secret '$secret_name': ${NC}"
    
    # Check if input is empty
    if [ -z "$password" ]; then
      echo -e "${RED}Warning: Empty value provided for '$secret_name'. Skipping...${NC}"
      continue
    fi
    
    # Remove existing secret if needed
    if [[ "$replace_podman" == true ]]; then
      podman secret rm "$secret_name" > /dev/null
    fi
    
    # Create the secret
    echo "$password" | podman secret create "$secret_name" -
    
    # Check if secret was created successfully
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Podman secret '$secret_name' created successfully!${NC}"
    else
      echo -e "${RED}Failed to create Podman secret '$secret_name'.${NC}"
    fi
  done
  
  echo -e "\n${GREEN}=== Secret creation process completed ===${NC}"
  
  # Show summary for Podman
  echo -e "${BLUE}Summary of Podman secrets:${NC}"
  podman secret ls | grep -E $(echo "${SECRET_NAMES[@]}" | sed 's/ /|/g') || echo "No matching Podman secrets found."
}

# Run the main function
create_secrets
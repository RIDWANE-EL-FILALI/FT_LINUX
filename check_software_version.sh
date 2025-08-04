#!/usr/bin/env bash

JSON_FILE=$1

if [[ -z "$JSON_FILE" ]]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

# Compare versions: true if $1 >= $2
function Compare_Versions()
{
    [[ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" == "$2" ]]
}

# Get current version of a tool
function get_current_version()
{
    if [[ "$1" == "kernel" ]]; then
        uname -r | grep -oE '^[0-9]+(\.[0-9]+)+'
        return
    fi

    if command -v "$1" >/dev/null 2>&1; then
        version=$("$1" --version 2>&1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1)
        echo "$version"
    else
        echo "NOT INSTALLED !"
    fi
}

# Extract tools and kernel objects correctly from JSON array
tools_obj=$(jq -r '.[0]' "$JSON_FILE")
kernel_obj=$(jq -r '.[1]' "$JSON_FILE")

# Extract kernel key and expected version
kernel_key=$(echo "$kernel_obj" | jq -r 'keys_unsorted[0]')
expected_kernel_version=$(echo "$kernel_obj" | jq -r '.[]')

# Check kernel version first
current_kernel_version=$(get_current_version "$kernel_key")

echo "Checking kernel version..."
if [[ "$current_kernel_version" == "NOT INSTALLED !" ]]; then
    printf "%-15s : \e[31mNOT INSTALLED !\e[0m ❌\n" "$kernel_key"
elif Compare_Versions "$expected_kernel_version" "$current_kernel_version"; then
    printf "\e[1;32m%-15s\e[0m | Expected: \e[32m%-10s\e[0m | Current: \e[32m%s\e[0m ❌\n" \
        "$kernel_key" "$expected_kernel_version" "$current_kernel_version"
else
    printf "\e[1;33m%-15s\e[0m | Expected: \e[33m%-10s\e[0m | Current: \e[31m%s\e[0m ✅\n" \
        "$kernel_key" "$expected_kernel_version" "$current_kernel_version"
fi
echo "----------------------------"

# Loop through tools keys
tools=($(echo "$tools_obj" | jq -r 'keys_unsorted[]'))

for tool in "${tools[@]}"; do
    expected_version=$(echo "$tools_obj" | jq -r --arg key "$tool" '.[$key]')
    current_version="$(get_current_version "$tool")"

    if [[ "$current_version" == "NOT INSTALLED !" ]]; then
        printf "%-15s : \e[31mNOT INSTALLED !\e[0m ❌\n" "$tool"
    else
        if Compare_Versions "$expected_version" "$current_version"; then
            printf "\e[1;32m%-15s\e[0m | Expected: \e[32m%-10s\e[0m | Current: \e[32m%s\e[0m ❌\n" \
                "$tool" "$expected_version" "$current_version"
        else
            printf "\e[1;33m%-15s\e[0m | Expected: \e[33m%-10s\e[0m | Current: \e[31m%s\e[0m ✅\n" \
                "$tool" "$expected_version" "$current_version"
        fi
    fi
done

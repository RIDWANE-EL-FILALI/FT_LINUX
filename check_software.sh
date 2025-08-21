#!/usr/bin/env bash

JSON_FILE=$1

# Check if JSON file is provided
if [ -z "$JSON_FILE" ]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

# Simple function to compare versions
# Returns 0 if current >= required, 1 otherwise
compare_versions() {
  REQUIRED=$1
  CURRENT=$2
  if [ "$REQUIRED" = "$CURRENT" ]; then
    return 0
  fi

  # Split versions into arrays
  IFS='.' read -r -a R <<< "$REQUIRED"
  IFS='.' read -r -a C <<< "$CURRENT"

  for i in 0 1 2; do
    if [ -z "${C[i]}" ]; then C[i]=0; fi
    if [ -z "${R[i]}" ]; then R[i]=0; fi

    if [ "${C[i]}" -gt "${R[i]}" ]; then
      return 0
    elif [ "${C[i]}" -lt "${R[i]}" ]; then
      return 1
    fi
  done
  return 0
}

# Get current version of a tool
get_version() {
  TOOL=$1
  if [ "$TOOL" = "kernel" ]; then
    uname -r | grep -oE '^[0-9]+(\.[0-9]+)+' 2>/dev/null
    return
  fi

  if command -v "$TOOL" >/dev/null 2>&1; then
    "$TOOL" --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1
  else
    echo "NOT INSTALLED"
  fi
}

# Load JSON
TOOLS=$(jq -r '.[0]' "$JSON_FILE")
KERNEL=$(jq -r '.[1]' "$JSON_FILE")

# Check kernel
KNAME=$(echo "$KERNEL" | jq -r 'keys_unsorted[0]')
KREQ=$(echo "$KERNEL" | jq -r '.[]')
KCUR=$(get_version "$KNAME")

echo "Checking kernel..."
if [ "$KCUR" = "NOT INSTALLED" ]; then
  echo "$KNAME : NOT INSTALLED ❌"
else
  compare_versions "$KREQ" "$KCUR"
  if [ $? -eq 0 ]; then
    echo "$KNAME : $KCUR ✅"
  else
    echo "$KNAME : $KCUR ❌"
  fi
fi
echo "----------------------"

# Check tools
for TOOL in $(echo "$TOOLS" | jq -r 'keys_unsorted[]'); do
  REQ=$(echo "$TOOLS" | jq -r --arg key "$TOOL" '.[$key]')
  CUR=$(get_version "$TOOL")

  if [ "$CUR" = "NOT INSTALLED" ]; then
    echo "$TOOL : NOT INSTALLED ❌"
  else
    compare_versions "$REQ" "$CUR"
    if [ $? -eq 0 ]; then
      echo "$TOOL : $CUR ✅"
    else
      echo "$TOOL : $CUR ❌"
    fi
  fi
done


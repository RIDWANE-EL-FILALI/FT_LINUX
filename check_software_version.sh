#!/usr/bin/env bash

JSON_FILE=$1

# get two versions sort them in ascending order then compare it with the least version requested 
function Compare_Versions()
{
    [["$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" == "$2"]]
}


# functions get the current version for each tool requested and returns it
function get_current_version()
{
    if command -v "$1" >/dev/null 2>&1; then
        version=$("$1" --version | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1)
        echo "$version"
    else
        echo "NOT INSTALLED !"
    fi
}

# Lopp throught the json file and check versions properly 
tools=($(jq -r 'keys_unsorted[]' "$JSON_FILE"))
for tool in "${tools[@]}"; do
    name=$tool
    expected_version=$(jq -r --arg key "$tool" '.[$key]' "$JSON_FILE")
    current_version_on_machine="$(get_current_version $tool)"
    printf "\e[1:32m${tool}\e[0m - \e[33m${expected_version}\e[0m - \e[33m${current_version_on_machine}\e[0m\n"
done

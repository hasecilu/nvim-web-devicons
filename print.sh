#!/usr/bin/env bash

go_file="$HOME/git/github/lazygit/pkg/gui/presentation/icons/file_icons.go"
lua_file="$HOME/git/github/nvim-web-devicons/lua/nvim-web-devicons/icons-default.lua"
rust_file="$HOME/git/github/eza/src/output/icons.rs"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Print keys that are missing on eza with rust formatting
lua_keys_to_rust_file() {
	while IFS= read -r line; do
		if [[ $line =~ \[\"(.+)\"\] ]]; then
			key="${BASH_REMATCH[1]}"
			# Search for the key in the Rust file
			rust_line=$(grep -F "\"$key\"" "$rust_file")
			if [ -n "$rust_line" ]; then
				# echo -e "${GREEN}$key found $(basename $rust_file)${NC}"
				found=1
				continue
			else
				# echo -e "${RED}$key not found on $(basename $rust_file)${NC}"
				found=0
				# NOTE: "=>" start at position 27: 26 char before, 4 ' ', 2 '"'
				spaces1=$(printf '%*s' $((26 - 4 - 2 - ${#key})) "")
				echo -n "    \"$key\"$spaces1=> '\u{"
			fi
		elif [[ $line =~ "    icon = " ]]; then
			if [ $found -eq 0 ]; then
				# Extract glyph
				glyph=$(echo $line | cut -d \" -f2 | cut -d \" -f1)
				# NOTE: "//" start at position 53: 36 constant chars
				unicode_length=$(printf "%04x" "'$glyph" | wc -c)
				spaces2=$(printf '%*s' $((52 - 39 - ${#unicode_length})) "")
				printf "%04x" "'$glyph"
				echo "}',$spaces2// $glyph"
			fi
		elif [[ $line =~ "    color = " ]]; then
			continue
		elif [[ $line =~ "    cterm_color = " ]]; then
			continue
		elif [[ $line =~ "    name = " ]]; then
			continue
		fi
	done <"$lua_file"
}

# Print keys that are missing on lazygit with go formatting
lua_keys_to_go_file() {
	while IFS= read -r line; do
		if [[ $line =~ \[\"(.+)\"\] ]]; then
			key="${BASH_REMATCH[1]}"
			# Search for the key in the Rust file
			go_line=$(grep -F "\"$key\"" "$go_file")
			if [ -n "$go_line" ]; then
				# echo -e "${GREEN}$key found $(basename $rust_file)${NC}"
				found=1
				continue
			else
				# echo -e "${RED}$key not found on $(basename $rust_file)${NC}"
				found=0
				# NOTE: "=>" start at position 27: 26 char before, 4 ' ', 2 '"'
				spaces1=$(printf '%*s' $((19 - ${#key})) "")
				echo -en "\t\"$key\":$spaces1{Icon: \"\u"
			fi
		elif [[ $line =~ "    icon = " ]]; then
			if [ $found -eq 0 ]; then
				# Extract glyph
				glyph=$(echo $line | cut -d \" -f2 | cut -d \" -f1)
				# NOTE: "//" start at position 53: 36 constant chars
				unicode_length=$(printf "%04x" "'$glyph" | wc -c)
				printf "%04x" "'$glyph"
				echo -n '", Color: '
			fi
		elif [[ $line =~ "    color = " ]]; then
			continue
		elif [[ $line =~ "    cterm_color = " ]]; then
			if [ $found -eq 0 ]; then
				# Extract color
				color=$(echo $line | cut -d \" -f2 | cut -d \" -f1)
				echo "$color}, // $glyph"
			fi
		elif [[ $line =~ "    name = " ]]; then
			continue
		fi
	done <"$lua_file"
}

rust_keys_to_lua_file() {
	while IFS= read -r line; do
		if [[ "$line" =~ \"([^\"]+)\"[[:space:]]*=\> ]]; then
			key="${BASH_REMATCH[1]}"
			lua_line=$(grep -F "\"$key\"" "$lua_file")
			if [ -n "$lua_line" ]; then
				continue
				# echo -e "${GREEN}$key found in $(basename "$lua_file")${NC}"
			else
				echo -e "${RED}$key not found in $(basename "$lua_file")${NC}"
			fi
		fi
	done <"$rust_file"
}

# lua_keys_to_rust_file
lua_keys_to_go_file

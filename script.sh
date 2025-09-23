#!/usr/bin/bash
# ================================================
#         Subdomain Finder Script
# ================================================

# Color codes
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Timestamp for files
timestamp=$(date +%Y%m%d_%H%M%S)
mkdir -p results

# Output files
sub_file="results/subs_$timestamp.txt"
live_file="results/live_$timestamp.txt"
sorted_file="results/sorted_$timestamp.txt"
port_file="results/ports_$timestamp.txt"
log_file="results/log_$timestamp.txt"

# Logging
exec > >(tee -a "$log_file") 2>&1

# Welcome banner
echo -e "${CYAN}${BLINK}Welcome to the Subdomain Finder!${NC}"
echo -e "${CYAN}${BOLD}${UNDERLINE}Let's find some subdomains!${NC}"

# Function: animated loading
show_loading() {
    local duration=$1
    local interval=0.1
    local end_time=$((SECONDS + duration))
    while [ $SECONDS -lt $end_time ]; do
        echo -ne "${MAGENTA}Loading..${NC}\r"
        sleep $interval
    done
    echo -ne "\r\033[K"
}

# Function: spinner for background processes
show_spinner() {
    local pid=$!
    local delay=0.1
    local spinner='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        for i in $(seq 0 3); do
            echo -ne "${MAGENTA}\r${spinner:i:1}${NC}"
            sleep $delay
        done
    done
    echo -ne "\r\033[K"
}

# User input
echo -e "${YELLOW}"
read -p "Enter your domain (example.com): " domain
echo -e "${NC}"

# Start enumeration
echo -e "${GREEN}Finding subdomains for $domain...${NC}"
(assetfinder "$domain" > "$sub_file") & show_spinner
wait

# Optional: use sublist3r if installed
if command -v sublist3r &>/dev/null; then
    echo -e "${GREEN}Running Sublist3r for $domain...${NC}"
    (sublist3r -d "$domain" -o "results/sublist3r_$timestamp.txt") & show_spinner
    wait
    cat "results/sublist3r_$timestamp.txt" >> "$sub_file"
fi

# Remove duplicates
sort -u "$sub_file" -o "$sub_file"

# Check live domains
echo -e "${MAGENTA}Checking live subdomains...${NC}"
(cat "$sub_file" | httprobe > "$live_file") & show_spinner
wait

# Sort live subdomains and count
sort -u "$live_file" -o "$sorted_file"
count=$(wc -l < "$sorted_file")
echo -e "${GREEN}Total live subdomains found: $count${NC}"

# Display sorted live subdomains
echo -e "${GREEN}Here are your live subdomains:${NC}"
while read sub; do
    if [[ "$sub" == https* ]]; then
        echo -e "${GREEN}$sub${NC}"
    else
        echo -e "${YELLOW}$sub${NC}"
    fi
done < "$sorted_file"

# Optional port scan
read -p "Do you want to scan ports 80 and 443 on live subdomains? (y/n): " scan_choice
if [[ "$scan_choice" =~ ^[Yy]$ ]]; then
    echo -e "${MAGENTA}Scanning ports 80 and 443...${NC}"
    while read sub; do
        nmap -Pn -p 80,443 "$sub" >> "$port_file"
    done < "$sorted_file"
    echo -e "${GREEN}Port scan completed! Results saved in $port_file${NC}"
fi

echo -e "${CYAN}${BOLD}All results are saved in the results/ folder.${NC}"
echo -e "${CYAN}Log file: $log_file${NC}"

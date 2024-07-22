#! /usr/bin/bash
# Color codes with multiple effects
BOLD='\033[1m'
UNDERLINE='\033[4m'
BlINK='\033[5m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No color
echo -e "${CYAN}${BLINK}Welcome to the Subdomain Finder!${NC}"
echo -e "${CYAN}${BOLD}${UNDERLINE}Let's find some subdomains!${NC}"
# Function for animated loading dots
show_loading() 
{
	local duration=$1
	local interval=0.1
	local end_time=$((SECONDS + duration))
	while [ $SECONDS  -lt  $end_time ]; do
echo -ne "${MAGENTA}
Loading..${NC}\r"
	sleep $interval 
	echo -ne "${MAGENTA}
Loading..${NC}\r"
	sleep $interval
	echo -ne "${MAGENTA}
Loading..${NC}\r"
	sleep $interval
	echo -ne "\r\033[k"  
#clear the line 
done
}
echo -e "${GREEN}Starting the process...${NC}"
show_loading 5 
# Show loading for 1 seconds               
echo "                              
         ______  ____ ______   
     ___|\     \|\    \ |\     \  
    |    |\     \\\    \| \     \ 
    |    |/____/| \|    \  \     |
 ___|    \|   | |  |     \  |    |
|    \    \___|/   |      \ |    |
|    |\     \      |    |\ \|    |
|\ ___\|_____|     |____||\_____/|
| |    |     |     |    |/ \|   ||
 \|____|_____|     |____|   |___|/
    \(    )/         \(       )/  "                             
echo ""
# Function for rotating bar animation
show_spinner()
{
	local pid=$!
	local delay=0.1
	local spinner='|/-\'
	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		for i in $(seq 0 3); do
			echo -ne "${MAGENTA}\r${spinner:i:1}${NC}"
			sleep $delay
			done
		done
		echo -ne "\r\033[K" # Clear the line
}
echo -e "${YELLOW}"
read -p "Enter your Domain : " test
echo -e "${NC}"
echo -e "${MAGENTA}Finding subdomains for $test...${NC}"         
(assetfinder synnefo.in > subs) & show_spinner  # Show spinner while running assetfinder
wait
# Prompt user to continue
read -p "Press [Enter] key to continue..."

echo -e "${MAGENTA}Checking live subdomains...${NC}"
(cat subs | httprobe > live ) & show_spinner # Show loading dots for 5 seconds
wait
# Prompt user to continue
read -p "Press [Enter] key to continue..."
echo -e "${MAGENTA}Sorting live subdomains...${NC}"
(sort -u live > sorted) & show_spinner  # Show spinner while sorting
wait
# Prompt user to continue
read -p "Press [Enter] key to display the results..."
echo -e "${GREEN}Here are your sorted live subdomains:${NC}" 
cat sorted

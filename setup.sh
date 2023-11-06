#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Function to display help message
usage() {
    echo -e "${YELLOW}Usage: $0 [OPTION]"
    echo -e "Set up the environment for phpnomad tests.\n"
    echo -e "Options:"
    echo -e "  --force    Setting this flag will cause this script to force-pull all repositories."
    echo -e "  --verbose  Show detailed output of process."
    echo -e "  --help     Display this help message and exit.${NC}\n"
    exit 1
}

# Initialize parameters
FORCE=0
VERBOSE=0

# Parse command-line arguments
while [ ! -z "$1" ]; do
    case "$1" in
        --force)
            FORCE=1
            ;;
        --verbose)
            VERBOSE=1
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
    shift
done

if [ $FORCE -eq 1 ]; then
    # When --force flag is set, remove the directory before creating it
    echo -e "${YELLOW}The --force flag is set. Re-building dependencies.${NC}"
    rm -rf plugins/phpnomad/lib
fi

mkdir -p plugins/phpnomad/lib

# Extract package paths from composer.json using jq
packages=$(jq -r '.repositories[] | select(.type=="path") .url' plugins/phpnomad/composer.json)

# Calculate the total number of packages
total_packages=$(echo "$packages" | wc -l)
processed_packages=0

# Function to print progress bar
print_progress_bar() {
    processed_percentage=$((processed_packages * 100 / total_packages))
    progress_bar=$(printf '%*s' "$processed_percentage" '' | tr ' ' '#')

    # Print the progress bar with carriage return (\r) to keep updates in the same line
    printf "\r[%-100s] %d%%" "$progress_bar" "$processed_percentage"
}

echo -e "${BLUE}Cloning repositories...${NC}"

# Clone repositories and update progress bar
for package in $packages; do
    # Construct GitHub URL and determine the repo name
    repo=$(echo $package | sed 's|\./lib/|git@github.com:phpnomad/|' | sed 's|$|.git|')
    repo_name=$(basename $package)

    # Clone the repository
    if [ $VERBOSE -eq 1 ]; then
        git clone $repo "plugins/phpnomad/lib/$repo_name"
    else
        git clone $repo "plugins/phpnomad/lib/$repo_name" > /dev/null 2>&1
        # Update processed packages count and print the progress bar
        ((processed_packages++))
        print_progress_bar
    fi
done

# Print newline to offset the next echo from the progress bar
echo ""

echo -e "${BLUE}Installing plugin package...${NC}"
# Install dependencies via composer
if [ $VERBOSE -eq 1 ]; then
    composer install -d plugins/phpnomad
else
    composer install -d plugins/phpnomad --quiet
fi

echo -e "${BLUE}Installing test packages...${NC}"
if [ $VERBOSE -eq 1 ]; then
    composer install -d tests
else
    composer install -d tests --quiet
fi

echo -e "${BLUE}Setting up docker...${NC}"

# Set up Docker
if [ $VERBOSE -eq 1 ]; then
    docker-compose build
    docker-compose up -d
else
    docker-compose build > /dev/null 2>&1
    docker-compose up -d > /dev/null 2>&1
fi

# Wait for the database container to be ready
while ! docker-compose exec -T db mysql -h"db" -utest -ptest -e "SELECT 1" &>/dev/null; do
    echo -e "${YELLOW}⏳ Waiting for the database container to start...${NC}"
    sleep 2
done

echo -e "${GREEN}✅ All-set! You should now be able to run ./run-tests.sh to run the actual tests.${NC}"

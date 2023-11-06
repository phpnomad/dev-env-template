#!/bin/bash

# run-tests.sh

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display help message
usage() {
    echo -e "${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo "Run specified WordPress tests."
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  --help                  Display this help and exit."
    echo "  --test-case=TestCase    Run all tests in the specified test case."
    echo "  --test-method=TestMethod Run a specific test method within the specified test case (requires --test-case)."
    echo ""
    echo "Without any options, the default behavior is to run all tests."
    exit 1
}

# Initialize parameters
TESTCASE=""
TESTMETHOD=""

# Parse command-line arguments
while [ "$1" != "" ]; do
    case "$1" in
        --test-case=* )
            TESTCASE="${1#*=}"
            ;;
        --test-method=* )
            TESTMETHOD="${1#*=}"
            ;;
        --help )
            usage
            ;;
        * )
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
    shift
done

# Ensure the script stops on first error
set -e

if [ -z "$TESTCASE" ] && [ -z "$TESTMETHOD" ]; then
    echo -e "${GREEN}✅ No specific test or test case provided. Running all tests.${NC}"
elif [ -n "$TESTCASE" ] && [ -z "$TESTMETHOD" ]; then
    echo -e "${GREEN}✅ Running specific test case: $TESTCASE${NC}"
elif [ -n "$TESTCASE" ] && [ -n "$TESTMETHOD" ]; then
    echo -e "${GREEN}✅ Running specific test method: $TESTCASE::$TESTMETHOD${NC}"
else
    echo -e "${RED}❌ Invalid options supplied. --test-method requires --test-case.${NC}"
    echo -e "${GREEN}Usage: $0 [OPTIONS]${NC}"
    exit 1
fi

# Navigate to the script directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# Try to Install WordPress.
docker-compose run --rm -T wpcli db reset --yes > /dev/null 2>&1
docker-compose run --rm -T wpcli core install --url=http://localhost:8000 --title=phpnomadTests --admin_user=admin --admin_password=admin --admin_email=ad@min.com > /dev/null 2>&1

# Function to run tests based on provided options
run_tests() {
    if [ -z "$TESTCASE" ] && [ -z "$TESTMETHOD" ]; then
        docker-compose exec -T wordpress bash -c "cd /var/www/html && phpunit -c /var/www/html/tests/phpunit.xml"
    elif [ -n "$TESTCASE" ] && [ -z "$TESTMETHOD" ]; then
        docker-compose exec -T wordpress bash -c "cd /var/www/html && phpunit -c /var/www/html/tests/phpunit.xml --filter $TESTCASE"
    elif [ -n "$TESTCASE" ] && [ -n "$TESTMETHOD" ]; then
        docker-compose exec -T wordpress bash -c "cd /var/www/html && phpunit -c /var/www/html/tests/phpunit.xml --filter $TESTCASE::$TESTMETHOD"
    else
        echo -e "${RED}❌ Invalid options supplied. --test-method requires --test-case.${NC}"
        echo -e "${GREEN}Usage: $0 [OPTIONS]${NC}"
        exit 1
    fi
}

# Call the function to run the tests
run_tests

#!/bin/bash

# This script checks and verifies the signature of a given directory of JAR files reverse.
# Usage: ./check_verify_of_jar_file.sh <path_of_jar_files>
# It lists each JAR file and indicates whether it is signed or not.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_of_jar_files>"
    exit 1
fi

jar_files_path="$1"

GREEN='\033[1;32m' green='\033[0;32m'  WHITE='\e[1;37m'   NC='\033[0m' # No Color       
RED='\033[1;31m'   red='\033[0;31m'    YELLOW='\E[1;33m'  yellow='\E[0;33m'    
BLUE='\E[1;34m'    blue='\E[0;34m'     PINK='\E[1;35m'    pink='\E[0;35m'  
purple='\e[0;35m'  PURPLE='\e[1;35m'   cyan='\e[0;36'     CYAN='\e[1;36m'


if [ ! -d "$jar_files_path" ]; then
    echo "Error: Directory $jar_files_path does not exist."
    exit 1
fi

check_verify_info(){
    local jar_file="$1"
    echo "Checking JAR file: $jar_file"
    
    # # Check if the JAR file is signed
    # if jarsigner -verify "$jar_file" &> /dev/null; then
    #     echo "The JAR file '$jar_file' is signed and verified."
    #     jarsigner -verify -verbose -certs "$jar_file"
    # else
    #     echo "The JAR file '$jar_file' is NOT signed or verification failed."
    # fi
    jarsigner -verify  -certs "$jar_file" | grep "未签名" >/dev/null
    if [ $? -eq 0 ]; then
        echo -e "The JAR file ${RED} '$jar_file' is ${YELLOW} NOT signed.${NC}"
    else
        echo -e "The JAR file ${GREEN} '$jar_file' is ${cyan}signed.${NC}"
        jarsigner -verify -verbose -certs "$jar_file"
    fi
}

find "$jar_files_path" -type f -name "*.jar" 2>/dev/null | while read -r jar_file; do
    check_verify_info "$jar_file"
    echo "========================================================================================="
done

echo "JAR file verification completed."
echo "If you encounter any issues, please check the JAR files and their signatures."
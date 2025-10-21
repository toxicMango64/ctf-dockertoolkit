#!/bin/bash

# repo path
repoPath=$(find $HOME -type d -name 42-ValgrindContainer 2>/dev/null)

chmod a+x $repoPath/stop && chmod a+x $repoPath/start && chmod a+x $repoPath/run && chmod a+x $repoPath/bgnd

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GRAY='\033[0;37m'
NC='\033[0m'

echo -e "${YELLOW}Are you in 42 lab? (y/n)${NC}"
read answer42

if [ "$answer42" = "y" ] || [ "$answer42" = "Y" ]; then
    echo -e "${GREEN}Are in 42 lab${NC}"
    if [ -x "$(command -v docker-compose)" ]; then
        echo -e "${GREEN}Good news, you have docker on your system 😎😁${NC}"
        sleep 1
        if [ "$(docker ps)" ]; then
            echo -e "${YELLOW}Docker is running, we will kill it${NC}"
            test -z "$(docker ps -q 2>/dev/null)" && osascript -e 'quit app "Docker"'
            sleep 1
        fi
    else
      echo -e "${RED}You need install docker on your system from${NC} "
      sleep 2
      echo -e "${YELLOW}Managed Software Center will Open Now${NC}"
      echo -e "${YELLOW}if Docker install is done please close Managed Software Center to continue ${NC}"
      # open Managed Software Center
      open -a '/Applications/Managed Software Center.app/Contents/MacOS/Managed Software Center'
    fi
    echo -e "${YELLOW}Is Docker Installed, Please wait for docker installation to complete? (y/n)${NC}"
    read answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        echo -e "${GREEN}Good${NC}"
    else
        echo -e "${RED}You are not in a 42 lab${NC}"
        exit 1
    fi

    rm -rf ~/goinfre/docker
    echo -e "${YELLOW}Wait till docker is Running${NC}"
    mkdir -p ~/goinfre/com.docker.docker
    echo -e "${GRAY}mkdir -p ~/goinfre/com.docker.docker${NC}"
    sleep 1
    rm -rf ~/Library/Containers/com.docker.docker
    echo -e "${GRAY}rm -rf ~/Library/Containers/com.docker.docker${NC}"
    sleep 1
    ln -s ~/goinfre/com.docker.docker ~/Library/Containers/com.docker.docker
    echo -e "${GRAY}ln -s ~/goinfre/com.docker.docker ~/Library/Containers/com.docker.docker${NC}"
    sleep 1
    echo -e "${YELLOW}Did you install zsh on your Mac? (y/n)${NC}"
    read answerzsh
    if [ "$answerzsh" = "y" ] || [ "$answerzsh" = "Y" ]; 
      then

        echo -e "${GREEN}add path to ${YELLOW}~/.zshrc${NC}"
        sleep 1
        # check if path is in .zshrc
        if grep -q "42-ValgrindContainer" ~/.zshrc; then
            echo -e "${GREEN}path is in .zshrc${NC}"
        else
            echo -e "${GRAY}add path to .zshrc${NC}"
            echo PATH=\$PATH:$(pwd)  | tee -a ~/.zshrc
            source ~/.zshrc
            echo -e "${GREEN}path added to .zshrc${NC}"
        fi
      else
        if grep -q "42-ValgrindContainer" ~/.bashrc; then
            echo -e "${GREEN}path is in .bashrc${NC}"
        else
            echo -e "${GRAY}add path to .bashrc${NC}"
            echo PATH=\$PATH:$(pwd)  | tee -a ~/.bashrc
            source ~/.bashrc
            echo -e "${GREEN}path added to .bashrc${NC}"
        fi
    fi # end if answerzsh
    open -a Docker
    # loop docker ps if true break loop
    while true; do
        docker ps > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Docker is running${NC}"
            break
        else
            echo -e "${RED}Waiting for Docker to run${NC}"
            sleep 1
        fi
    done
else
  echo -e "${RED}Only For 42 labs, Thanks for all the FISH${NC}"
  exit
fi  

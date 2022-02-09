#!/bin/bash

#Example: '\033[<background>;<foreground>m'
GREEN='\033[1;32m';
YELLOW='\033[0;33m';
LIGHT_RED='\033[1;31m';
SSH_KEY_COLOR='\033[44;93m';
ERROR_COLOR='\033[41;33m';
NO_COLOR='\033[0m';

clear;
echo -e "${YELLOW}Hello $('whoami').";
read -p "Please type your e-mail address: " email;

ssh-keygen -t ed25519 -C $email;

eval "$(ssh-agent -s)";

ssh-add ~/.ssh/id_ed25519;

clear;

echo -e "${GREEN}Your SSH Key was successful generated!${YELLOW}";
echo;

while true; do
    read -p "Would you like to add the key to your github account? (y/n): " option
    echo;
    case $option in
        [Yy]* )
            read -p "GitHub username: " username;
            read -p "Paste your GitHub Personal access token: " token;
            echo;
            hostname=$('hostname');
            ssh_key=$(<~/.ssh/id_ed25519.pub);
            data='{"title":"'$hostname'","key":"'$ssh_key'"}';
            response=$(curl -s -w "%{http_code}\n" \
            -u $username:$token \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/user/keys \
            -d "$data" \
            -o /dev/null);
            if [ "$response" == "201" ]; then
                echo -e "${GREEN}SSH Key successful added!${YELLOW}";
            else
                echo -e "${LIGHT_RED}Error trying to add SSH Key. Status code: ${ERROR_COLOR} ${response} ${NO_COLOR}${LIGHT_RED} (see GitHub API documentation).${YELLOW}";
            fi
            exit 1;;
        [Nn]* )
            echo -e "Your SSH key is:";
            echo -e $SSH_KEY_COLOR;
            cat ~/.ssh/id_ed25519.pub;
            echo -e "${NO_COLOR}${LIGHT_RED}(Key already copied to clipboard)${YELLOW}";
            cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard;
            exit 1;;
        * ) echo -e "${LIGHT_RED}Please answer yes or no.${YELLOW}";;
    esac
done

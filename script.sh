#!/bin/bash

echo "Hello $('whoami').";

read -p "Please type your e-mail address: " email;

ssh-keygen -t ed25519 -C $email -f ~/.ssh/$email -N '';

eval "$(ssh-agent -s)";

ssh-add ~/.ssh/$email;

clear;

echo "Your SSH Key was successful generated!";
echo

while true; do
    read -p "Would you like to add the key to your github account? (y/n): " option
    echo;
    case $option in
        [Yy]* )
            read -p "GitHub username: " username;
            read -p "Paste your GitHub Personal access token: " token;
            echo;
            hostname=$('hostname');
            ssh_key=$(<~/.ssh/$email.pub);
            data='{"title":"'$hostname'","key":"'$ssh_key'"}';
            response=$(curl -s -w "%{http_code}\n" \
            -u $username:$token \
            -X POST \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/user/keys \
            -d "$data" \
            -o /dev/null);
            if [ "$response" == "201" ]; then
                echo "SSH Key successful added!";
            else
                echo "Error trying to add SSH Key. Status code: $response (see GitHub API documentation).";
            fi
            exit 1;;
        [Nn]* )
            echo "Your SSH key is (Key already copied to clipboard):";
            echo;
            cat ~/.ssh/$email.pub;
            cat ~/.ssh/$email.pub | xclip -selection clipboard;
            exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
done

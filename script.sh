#!/bin/bash

apt install xclip;

clear;

echo "Hello $('whoami').";
echo "Please type your e-mail address:";

read email;

ssh-keygen -t ed25519 -C $email;

eval "$(ssh-agent -s)";

ssh-add ~/.ssh/id_ed25519;

clear;

echo "Your SSH key is (Key already copied to clipboard):";

cat ~/.ssh/id_ed25519.pub;

cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard;

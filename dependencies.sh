#!/bin/bash
[[ -z "$1" ]] && echo "Provide path to .bashrc (or other file) as a first argument..." && exit 1
_bashrc="$1"
[[ -f "$_bashrc" ]] || echo "$_bashrc do not exist." || exit 1

echo "Installing ruby, please, provide root password..."
sudo dnf install ruby ruby-devel openssl-devel redhat-rpm-config gcc-c++ @development-tools
[[ $? -eq 0 ]] && echo "Done!" || exit 1

echo "Preparing gems environment..."
echo '# Install Ruby Gems to ~/gems' >> "$_bashrc"
echo 'export GEM_HOME="$HOME/gems"' >> "$_bashrc"
echo 'export PATH="$HOME/gems/bin:$PATH"' >> "$_bashrc"
source "$_bashrc"
[[ $? -eq 0 ]] || echo "Failed to prepare gem env.!" || exit 1
echo "Done!"

echo "Installing jekyll and bundler..."
gem update --system
[[ $? -eq 0 ]] || echo "Failed to update gems" || exit 1
gem install jekyll bundler
[[ $? -eq 0 ]] || echo "Failed to install jekyll or bundler!" || exit 1
echo "Done!"

echo "Installing vafelka blog dependencies..."
bundle install || echo "Failed to install dependencies!" || exit 1
echo "Done!"

#!/bin/bash
# 💫 https://github.com/ShinjiMC 💫 #

if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

clear

printf "\n%.0s" {1..3}
echo "  ____  _     _           _ _ __  __  ____ "
echo " / ___|| |__ (_)_ __     (_(_)  \/  |/ ___|"
echo " \___ \| '_ \| | '_ \ _  | | | |\/| | |    "
echo "  ___) | | | | | | | | |_| | | |  | | |___ "
echo " |____/|_| |_|_|_| |_|_____|_|_|  |_|\____|"
printf "\n%.0s" {1..2}


zsh=(
    eza
    fzf
    zsh 
    util-linux
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$SCRIPT_DIR/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_zsh.log"

COUNTER=1
while [ -f "$LOG" ]; do
  LOG="Install-Logs/install-$(date +%d-%H%M%S)_${COUNTER}_zsh.log"
  ((COUNTER++))
done

printf "${NOTE} Installing core zsh packages...${RESET}\n"
for ZSHP in "${zsh[@]}"; do
  install_package "$ZSHP" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
     echo -e "\e[1A\e[K${ERROR} - $ZSHP Package installation failed, Please check the installation logs"
  fi
done

printf "\n"

while true; do
    read -p "${CAT} Do you want to install Pokemon color scripts? (y/n): " choice
    case "$choice" in
        [Yy]*)
            if [ -d "$SCRIPT_DIR/pokemon-colorscripts" ]; then
                pushd "$SCRIPT_DIR/pokemon-colorscripts" > /dev/null
                git pull && sudo ./install.sh
                popd > /dev/null
            else
                git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$SCRIPT_DIR/pokemon-colorscripts" &&
                pushd "$SCRIPT_DIR/pokemon-colorscripts" > /dev/null
                sudo ./install.sh
                popd > /dev/null
            fi
            sed -i '/#pokemon-colorscripts --no-title -s -r/s/^#//' "$SCRIPT_DIR/assets/.zshrc" >> "$LOG" 2>&1
            echo "${NOTE} Pokemon Installation process completed" 2>&1 | tee -a "$LOG"
            ;;
        [Nn]*) 
            echo "${ORANGE} You chose not to install Pokemon Color Scripts." 2>&1 | tee -a "$LOG"
            ;;
        *)
            echo "Please enter 'y' for yes or 'n' for no." 2>&1 | tee -a "$LOG"
            continue
            ;;
    esac
    break
done


printf "\n"

if command -v zsh >/dev/null; then
  printf "${NOTE} Installing Oh My Zsh and plugins...\n"
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
  		sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
	else
		echo "Directory .oh-my-zsh already exists. Skipping re-installation." 2>&1 | tee -a "$LOG"
	fi
	if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
	else
    	echo "Directory zsh-autosuggestions already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
	fi

	if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || true
	else
    	echo "Directory zsh-syntax-highlighting already exists. Skipping cloning." 2>&1 | tee -a "$LOG"
	fi
	if [ -f "$HOME/.zshrc" ]; then
    	cp -b "$HOME/.zshrc" "$HOME/.zshrc-backup" || true
	fi

	if [ -f "$HOME/.zprofile" ]; then
    	cp -b "$HOME/.zprofile" "$HOME/.zprofile-backup" || true
	fi

    cp -r "$SCRIPT_DIR/assets/.zshrc" ~/
    cp -r "$SCRIPT_DIR/assets/.zprofile" ~/

    printf "${NOTE} Changing default shell to zsh...\n"

	while ! chsh -s $(which zsh); do
    echo "${ERROR} Authentication failed. Please enter the correct password."
    sleep 1	
	done
	printf "\n"
	printf "${NOTE} Shell changed successfully to zsh.\n" 2>&1 | tee -a "$LOG"

fi

if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "${NOTE} Current shell is not zsh."
    shell_config=""
    case "$SHELL" in
        "/bin/bash")
            shell_config="$HOME/.bashrc"
            ;;
        "/bin/fish")
            shell_config="$HOME/.config/fish/config.fish"
            ;;
        "/bin/sh")
            shell_config="$HOME/.profile"
            ;;
        *)
            echo "${ERROR} Unsupported shell. Exiting..."
            exit 1
            ;;
    esac
    if [ -f "$shell_config" ]; then
        cp -b "$shell_config" "${shell_config}-backup" || true
        echo "${NOTE} Backup created for $shell_config"
    fi
    echo "exec /usr/bin/zsh" >> "$shell_config"
    echo "${NOTE} Added 'exec /usr/bin/zsh' to $shell_config"
fi

clear


printf "\n%.0s" {1..3}
echo "  ____  _     _           _ _ __  __  ____ "
echo " / ___|| |__ (_)_ __     (_(_)  \/  |/ ___|"
echo " \___ \| '_ \| | '_ \ _  | | | |\/| | |    "
echo "  ___) | | | | | | | | |_| | | |  | | |___ "
echo " |____/|_| |_|_|_| |_|_____|_|_|  |_|\____|"
printf "\n%.0s" {1..2}
echo "${NOTE} Enjoy your NEW TERMINAL" 2>&1 | tee -a "$LOG"
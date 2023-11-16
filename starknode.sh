#!/bin/bash

echo "=============================================================="
echo -e "\033[0;35m"
echo "███████╗████████╗ █████╗ ██████╗ ██╗  ██╗   ";
echo "██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██║ ██╔╝   ";
echo "███████╗   ██║   ███████║██████╔╝█████╔╝    ";
echo "╚════██║   ██║   ██╔══██║██╔══██╗██╔═██╗    ";
echo "███████║   ██║   ██║  ██║██║  ██║██║  ██╗   ";
echo "╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ";
echo -e "\e[0m"          
echo "=============================================================="
#Made by Haxxana
sleep 3
echo " "

function alchemy {
read -p "Insert ALCHEMY HTTPS API ADDRESS: " ALCHEMY 
echo 'export ALCHEMY='$ALCHEMY >> $HOME/.bash_profile
}



function Installingrequiredtool {
echo " "
echo -e "\e[1m\e[32mInstalling required tool ... \e[0m" && sleep 1
sudo apt install curl -y < "/dev/null"
sudo apt update && sudo apt install git pkg-config libssl-dev libzstd-dev protobuf-compiler -y < "/dev/null"
}


function Installingrustup {
echo " "
echo -e "\e[1m\e[32mPreparing to install rustup ... \e[0m" && sleep 1
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
source $HOME/.bash_profile
rustup update stable --force
}


function starknet {
echo " "
echo -e "\e[1m\e[32mPreparing to install starknet  ... \e[0m" && sleep 1
mkdir -p $HOME/.starknet/db
cd $HOME
rm -rf pathfinder
git clone https://github.com/eqlabs/pathfinder.git
cd pathfinder
git fetch
git checkout v0.9.5
cargo build --release --bin pathfinder
source $HOME/.bash_profile
sudo mv ~/pathfinder/target/release/pathfinder /usr/local/bin/
}


function createservice {
echo "[Unit]
Description=StarkNet
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url \"$ALCHEMY\" --data-directory \"$HOME/.starknet/db\"
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/starknetd.service
sudo mv $HOME/starknetd.service /etc/systemd/system/
}



function startstarknetd {
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable starknetd
sudo systemctl restart starknetd
}




function delete {
echo " "
echo -e "\e[1m\e[32mPreparing Delete Starknet node ... \e[0m" && sleep 1
systemctl stop starknetd
systemctl disable starknetd
rm -rf ~/pathfinder/
rm -rf /etc/systemd/system/starknetd.service
rm -rf /usr/local/bin/pathfinder
}






PS3='Please enter your choice (input your option number and press enter): '
options=("Install Starknet Node"  "Delete Starknet Node" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Install Starknet Node")
            echo -e '\e[1m\e[32mYou choose Install Starknet Node ...\e[0m' && sleep 1
alchemy
Installingrequiredtool
Installingrustup
starknet
createservice
startstarknetd
echo -e "\e[1m\e[32mYour Starknet Node Install!\e[0m" && sleep 1
break
;;


"Delete Starknet Node")
echo -e '\e[1m\e[32mYou choose Delete Starknet Node ...\e[0m' && sleep 1
delete
break

;;
"Quit")
break
;;

*) echo -e "\e[91minvalid option $REPLY\e[0m";;
    esac
done

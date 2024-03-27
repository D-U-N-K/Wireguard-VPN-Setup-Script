# Wireguard-VPN-Setup-Script
 Bash script for setting up WireGuard VPN server &amp; DNS resolver on Linux. Automates installation &amp; configuration, manages firewall, generates peer configs &amp; QR codes. Efficient &amp; user-friendly.

''' __          __ _              _____                         _  __      __ _____   _   _    _____        _                    _____              _         _   '''
''' \ \        / /(_)            / ____|                       | | \ \    / /|  __ \ | \ | |  / ____|      | |                  / ____|            (_)       | |  '''
''' \ \  /\  / /  _  _ __  ___ | |  __  _   _   __ _  _ __  __| |  \ \  / / | |__) ||  \| | | (___    ___ | |_  _   _  _ __   | (___    ___  _ __  _  _ __  | |_  '''
'''\ \/  \/ /  | || '__|/ _ \| | |_ || | | | / _` || '__|/ _` |   \ \/ /  |  ___/ | . ` |  \___ \  / _ \| __|| | | || '_ \   \___ \  / __|| '__|| || '_ \ | __|   '''
''' \  /\  /   | || |  |  __/| |__| || |_| || (_| || |  | (_| |    \  /   | |     | |\  |  ____) ||  __/| |_ | |_| || |_) |  ____) || (__ | |   | || |_) || |_    '''
'''  \/  \/    |_||_|   \___| \_____| \__,_| \__,_||_|   \__,_|     \/    |_|     |_| \_| |_____/  \___| \__| \__,_|| .__/  |_____/  \___||_|   |_|| .__/  \__|   '''
'''                                                                                                                 | |                            | |            '''
'''                                                                                                                 |_|                            |_|            '''

# Wireguard VPN Setup Script

## Description

This bash script automates the setup of a WireGuard VPN server and DNS resolver on Linux systems. It streamlines the installation of WireGuard, dnsmasq, qrencode, and iptables-persistent, and guides users through the configuration process.

## Features

- **Automated Setup:** Easily install and configure WireGuard, dnsmasq, qrencode, and iptables-persistent with a single script.
- **Firewall Management:** Open firewall ports to enable VPN traffic, ensuring secure communication.
- **Peer Configuration:** Generate peer configurations and QR codes for easy client setup.
- **User-Friendly:** Intuitive prompts and instructions make setup quick and straightforward.
- **Efficient:** Script handles package manager detection, IP forwarding, interface detection, and more.

## Usage

### Clone Repository

\`\`\`bash
git clone https://github.com/D-U-N-K/wireguard-vpn-setup.git
cd wireguard-vpn-setup
\`\`\`

### Make Script Executable

\`\`\`bash
chmod +x setup_wireguard_vpn.sh
\`\`\`

### Run the Script

\`\`\`bash
./setup_wireguard_vpn.sh
\`\`\`

Follow the prompts to configure your WireGuard VPN server and generate peer configurations.

## Requirements

- Linux operating system (Ubuntu, CentOS, etc.)
- Bash shell
- Superuser privileges (sudo)

## License

This project is licensed under the MIT License, allowing for unrestricted use, modification, and distribution.




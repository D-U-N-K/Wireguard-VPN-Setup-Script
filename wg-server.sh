#!/bin/bash

echo "Preparing to set up WireGuard VPN Server and DNS resolver..."

# Install WireGuard, dnsmasq, qrencode, and iptables-persistent
install_packages() {
    echo "Detecting package manager..."
    if [ -x "$(command -v apt-get)" ]; then
        echo "Using APT package manager"
        sudo apt-get update
        sudo apt-get install -y wireguard qrencode dnsmasq iptables-persistent
        FIREWALL_TOOL="ufw"
    elif [ -x "$(command -v yum)" ]; then
        echo "Using YUM package manager"
        sudo yum install -y epel-release
        sudo yum install -y wireguard-tools qrencode dnsmasq
        sudo yum install -y iptables-services
        sudo systemctl enable iptables
        FIREWALL_TOOL="firewall-cmd"
    else
        echo "Unsupported package manager. Please manually install WireGuard, dnsmasq, qrencode, and iptables-persistent."
        exit 1
    fi
}

install_packages

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# Detect the public network interface
detect_public_interface() {
    IP_ROUTE=$(ip route show default)
    INTERFACE=$(echo $IP_ROUTE | grep -oP 'dev \K\S+')
    echo $INTERFACE
}

SERVER_PUBLIC_INTERFACE=$(detect_public_interface)

# Configure WireGuard server
read -p "Enter the WireGuard IP for the server (e.g., 10.0.0.1/24): " SERVER_WG_IP
SERVER_DNS_IP=${SERVER_WG_IP%/*} # Extract IP without CIDR notation for DNS
read -p "Enter the VPN Listen Port (e.g., 51820): " WG_PORT
read -p "Enter the number of peers: " PEER_COUNT

# Opening VPN port on the firewall
echo "Opening VPN port $WG_PORT on the firewall..."
if [ "$FIREWALL_TOOL" = "ufw" ]; then
    sudo ufw allow $WG_PORT/udp
elif [ "$FIREWALL_TOOL" = "firewall-cmd" ]; then
    sudo firewall-cmd --permanent --add-port=$WG_PORT/udp
    sudo firewall-cmd --reload
else
    echo "Manual firewall configuration required."
fi

# Setup output directory
OUTPUT_DIR=./output
mkdir -p "${OUTPUT_DIR}"

# Generate server keys
wg genkey | tee "${OUTPUT_DIR}/server_private.key" | wg pubkey > "${OUTPUT_DIR}/server_public.key"
SERVER_PRIVATE_KEY=$(cat "${OUTPUT_DIR}/server_private.key")

# Create WireGuard config
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = ${SERVER_WG_IP}
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${SERVER_PUBLIC_INTERFACE} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${SERVER_PUBLIC_INTERFACE} -j MASQUERADE
EOF

# Save iptables rules
if [ "$FIREWALL_TOOL" = "ufw" ]; then
    sudo netfilter-persistent save
elif [ "$FIREWALL_TOOL" = "firewall-cmd" ]; then
    sudo service iptables save
fi

# Configure dnsmasq as DNS server
sudo bash -c "echo 'listen-address=127.0.0.1,${SERVER_DNS_IP}' > /etc/dnsmasq.conf"
sudo bash -c "echo 'bind-interfaces' >> /etc/dnsmasq.conf"
sudo systemctl restart dnsmasq

# Generate and configure peers
for ((i=1; i<=PEER_COUNT; i++)); do
    PEER_WG_IP="10.0.0.$((i+1))/32"
    wg genkey | tee "${OUTPUT_DIR}/peer${i}_private.key" | wg pubkey > "${OUTPUT_DIR}/peer${i}_public.key"
    PEER_PRIVATE_KEY=$(cat "${OUTPUT_DIR}/peer${i}_private.key")
    PEER_PUBLIC_KEY=$(cat "${OUTPUT_DIR}/peer${i}_public.key")

    cat <<EOF > "${OUTPUT_DIR}/peer${i}_wg0.conf"
[Interface]
PrivateKey = ${PEER_PRIVATE_KEY}
Address = ${PEER_WG_IP}
DNS = ${SERVER_DNS_IP}

[Peer]
PublicKey = $(cat "${OUTPUT_DIR}/server_public.key")
Endpoint = $(curl -s http://checkip.amazonaws.com):${WG_PORT}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

    qrencode -t PNG -o "${OUTPUT_DIR}/peer${i}_qr.png" < "${OUTPUT_DIR}/peer${i}_wg0.conf"
    echo "Configuration for peer ${i} completed."
done

chmod -R og-rwx "${OUTPUT_DIR}"

# Enable and start WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

echo "WireGuard VPN Server setup is complete. Peer configurations and QR codes are in the 'output' folder."

#!/bin/bash

run_the_node() {
    echo "Running the node setup..."
    
    # Update and upgrade the system
    sudo apt update && sudo apt upgrade -y

    # Install necessary packages
    sudo apt -qy install curl git jq lz4 build-essential screen
    sudo apt install -y docker.io

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
    mkdir -p "$DOCKER_CONFIG/cli-plugins"
    curl -SL "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
    chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"

    # Verify Docker Compose installation
    docker compose version

    # Test Docker installation
    docker run hello-world

    # Handle the repository cloning (override if it exists)
    if [ -d "infernet-container-starter" ]; then
        echo "Directory 'infernet-container-starter' already exists. Removing it..."
        rm -rf infernet-container-starter
    fi

    echo "Cloning the repository..."
    git clone https://github.com/ritual-net/infernet-container-starter
    cd infernet-container-starter || exit

    # Use a screen session to deploy the container and keep the script running
    screen -dmS ritual bash -c "project=hello-world make deploy-container"
    echo "The container deployment is running in a detached screen session named 'ritual'."
    echo "Use 'screen -r ritual' to reattach to the session if needed."
    # Call the configuration modification function
    #Sleep 25 seconds to make sure container is deployed. 
    sleep 25
    deploy_modify_config
    deploy_sol_modify
    hello_world_container_config
    make_file
    update_docker_compose
}


foundry_configuration() {
    echo "Starting Foundry configuration..."

    # Create and navigate to the Foundry directory
    echo "Setting up the Foundry directory..."
    mkdir -p ~/foundry
    cd ~/foundry || exit

    # Install Foundry
    echo "Installing Foundry..."
    curl -L https://foundry.paradigm.xyz | bash

    # Add Foundry to PATH and update the current session
    echo "Adding Foundry to PATH..."
    if ! grep -q "export PATH=\$HOME/.foundry/bin:\$PATH" ~/.bashrc; then
        echo 'export PATH=$HOME/.foundry/bin:$PATH' >> ~/.bashrc
    fi
    export PATH=$HOME/.foundry/bin:$PATH

    # Execute foundryup
    echo "Running foundryup..."
    if ! command -v foundryup &> /dev/null; then
        echo "Error: foundryup command not found. Exiting."
        exit 1
    fi
    foundryup

    # Verify Forge installation
    echo "Verifying Forge installation..."
    if ! command -v forge &> /dev/null; then
        echo "Error: Forge command not found. Exiting."
        exit 1
    fi
    echo "Forge installed successfully! Version: $(forge --version)"

    # Install Forge dependencies
    echo "Installing Forge dependencies..."
    cd ~/infernet-container-starter/projects/hello-world/contracts || { echo "Error: Directory not found."; exit 1; }
    if [ -d "lib/forge-std" ]; then
        echo "Removing existing forge-std directory..."
        rm -rf lib/forge-std
    fi
    if [ -d "lib/infernet-sdk" ]; then
        echo "Removing existing infernet-sdk directory..."
        rm -rf lib/infernet-sdk
    fi
    forge install --no-commit foundry-rs/forge-std || { echo "Error: Failed to install forge-std."; exit 1; }
    forge install --no-commit ritual-net/infernet-sdk || { echo "Error: Failed to install infernet-sdk."; exit 1; }
    cd ../../../

    echo "Foundry configuration completed successfully!"
}




update_docker_compose(){
    #!/bin/bash

DOCKER_COMPOSE_FILE="$HOME/infernet-container-starter/deploy/docker-compose.yaml"

# Check if the docker-compose.yaml file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "docker-compose.yaml file not found at $DOCKER_COMPOSE_FILE"
    exit 1
fi

# Define the old and new image versions
OLD_IMAGE="ritualnetwork/infernet-node:1.3.1"
NEW_IMAGE="ritualnetwork/infernet-node:1.4.0"

echo "Updating the image version in $DOCKER_COMPOSE_FILE..."

# Replace the old image with the new image
sed -i "s|$OLD_IMAGE|$NEW_IMAGE|" "$DOCKER_COMPOSE_FILE"

echo "Image version updated successfully to $NEW_IMAGE!"

}

make_file(){
    #!/bin/bash

MAKEFILE="$HOME/infernet-container-starter/projects/hello-world/contracts/Makefile"

# Check if the Makefile exists
if [ ! -f "$MAKEFILE" ]; then
    echo "Makefile not found at $MAKEFILE"
    exit 1
fi

# Prompt user for their private key
read -p "Enter your private key: " private_key

# Ensure the private key starts with "0x"
if [[ ${private_key:0:2} != "0x" ]]; then
    private_key="0x$private_key"
    echo "Private key updated to start with '0x'."
fi

# Set the RPC URL
rpc_url="https://mainnet.base.org/"

echo "Modifying $MAKEFILE..."

# Replace the sender private key with the user-provided key
sed -i "s|sender := .*|sender := $private_key|" "$MAKEFILE"

# Replace the RPC URL with the new value
sed -i "s|RPC_URL := .*|RPC_URL := $rpc_url|" "$MAKEFILE"

echo "Makefile updated successfully!"

}

deploy_sol_modify(){
    DEPLOY_FILE="$HOME/infernet-container-starter/projects/hello-world/contracts/script/Deploy.s.sol"

    # Check if the Deploy.s.sol file exists
    if [ ! -f "$DEPLOY_FILE" ]; then
    echo "File not found: $DEPLOY_FILE"
    exit 1
    fi

# Define the old and new registry addresses
    OLD_REGISTRY="0x663F3ad617193148711d28f5334eE4Ed07016602"
    NEW_REGISTRY="0xe2F36C4E23D67F81fE0B278E80ee85Cf0ccA3c8d"

# Replace the old registry address with the new one
    sed -i "s/$OLD_REGISTRY/$NEW_REGISTRY/" "$DEPLOY_FILE"

echo "Registry address updated successfully in $DEPLOY_FILE"
}

hello_world_container_config(){
    CONFIG_FILE="$HOME/infernet-container-starter/projects/hello-world/container/config.json"

    # Check if the config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found at $CONFIG_FILE"
        exit 1
    fi

    # Prompt user for their private key
    read -p "Enter your private key for hello world container: " private_key

    # Ensure the private key starts with "0x"
    if [[ ${private_key:0:2} != "0x" ]]; then
        private_key="0x$private_key"
        echo "Private key updated to start with '0x'."
    fi

    echo "Modifying $CONFIG_FILE..."

    # Modify the JSON file
    jq --arg private_key "$private_key" \
       --arg rpc_url "https://mainnet.base.org/" \
       --arg registry_address "0xe2F36C4E23D67F81fE0B278E80ee85Cf0ccA3c8d" \
    '
    # Add snapshot_sync object outside chain
    .snapshot_sync = {
        "sleep": 3,
        "starting_sub_id": 180000,
        "batch_size": 50,
        "sync_period": 30
    } |

    # Remove docker object
    del(.docker) |

    # Edit rpc_url
    .chain.rpc_url = $rpc_url |

    # Edit registry_address
    .chain.registry_address = $registry_address |

    # Update private_key
    .chain.wallet.private_key = $private_key |

    # Update trail_head_blocks to 3
    .chain.trail_head_blocks = 3
    ' "$CONFIG_FILE" > tmp_config.json && mv tmp_config.json "$CONFIG_FILE"

    echo "Changes applied successfully!"

    # Display the updated config for confirmation
    echo "Updated config:"
    cat "$CONFIG_FILE"
}

deploy_modify_config() {
    CONFIG_FILE="$HOME/infernet-container-starter/deploy/config.json"

    # Check if the config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found at $CONFIG_FILE"
        exit 1
    fi

    # Prompt user for their private key
    read -p "Enter your private key for deploy config: " private_key

    # Ensure the private key starts with "0x"
    if [[ ${private_key:0:2} != "0x" ]]; then
        private_key="0x$private_key"
        echo "Private key updated to start with '0x'."
    fi

    echo "Modifying $CONFIG_FILE..."

    # Modify the JSON file
    jq --arg private_key "$private_key" \
       --arg rpc_url "https://mainnet.base.org/" \
       --arg registry_address "0xe2F36C4E23D67F81fE0B278E80ee85Cf0ccA3c8d" \
    '
    # Add snapshot_sync object outside chain
    .snapshot_sync = {
        "sleep": 3,
        "starting_sub_id": 180000,
        "batch_size": 50,
        "sync_period": 30
    } |

    # Remove docker object
    del(.docker) |

    # Edit rpc_url
    .chain.rpc_url = $rpc_url |

    # Edit registry_address
    .chain.registry_address = $registry_address |

    # Update private_key
    .chain.wallet.private_key = $private_key |

    # Update trail_head_blocks to 3
    .chain.trail_head_blocks = 3
    ' "$CONFIG_FILE" > tmp_config.json && mv tmp_config.json "$CONFIG_FILE"

    echo "Changes applied successfully!"

    # Display the updated config for confirmation
    echo "Updated config:"
    cat "$CONFIG_FILE"
}


# Main menu
while true; do
    echo "=============================="
    echo "       Node Setup Script      "
    echo "=============================="
    echo "1. Run The Node"
    echo "2. Configure Foundry"
    echo "3. Exit"
    echo "=============================="

    read -p "Enter your choice [1-3]: " choice

    case $choice in
        1)
            run_the_node
            ;;
        2)
            foundry_configuration
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done

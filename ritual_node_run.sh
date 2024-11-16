#!/bin/bash

# Function to handle Off-chain option

run_the_node(){
 echo "Running Off-chain tasks..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y jq    
    echo "Installing required packages..."
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    echo "Adding Docker GPG key and repository..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    echo "Updating package list..."
    sudo apt-get update -y
    
    echo "Installing Docker..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Starting and enabling Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker

    echo "Installing Python 3 and pip..."
    sudo apt-get install -y python3 python3-pip
    
    echo "Setting Python alternatives..."
    sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
    
    echo "Installing Python 3.12 venv..."
    sudo apt install -y python3.12-venv
    
    echo "Creating and activating Python virtual environment..."
    python3 -m venv .venv
    source .venv/bin/activate
    
    echo "Installing Infernet CLI..."
    pip3 install infernet-cli
    
    echo "Cloning Infernet Container Starter repository..."
    git clone --recurse-submodules https://github.com/ritual-net/infernet-container-starter

    echo "Navigating to infernet-container-starter directory..."
    cd infernet-container-starter

    echo "Pulling Docker image..."
    docker pull ritualnetwork/hello-world-infernet:latest

    echo "Starting a screen session for deployment..."
    screen -S infernet-deploy -dm bash -c "make deploy-container project=hello-world"

}
off_chain() {
   

    echo "Response from POST request: $POST_RESPONSE"

    POST_RESPONSE=$(curl -s -X POST "http://127.0.0.1:4000/api/jobs" \
    -H "Content-Type: application/json" \
    -d '{"containers": ["hello-world"], "data": {"some": "input"}}')

    echo "Raw POST response: $POST_RESPONSE"

    JOB_ID=$(echo "$POST_RESPONSE" | jq -r '.id')
    if [ -z "$JOB_ID" ] || [ "$JOB_ID" == "null" ]; then
        echo "Error: Failed to retrieve job ID. Ensure the server is running and reachable."
        exit 1
    fi

    echo "*******************************"
    echo "Job ID retrieved: $JOB_ID"
    echo "*******************************"

    echo "Sending GET request with Job ID..."
    GET_RESPONSE=$(curl -s -X GET "http://127.0.0.1:4000/api/jobs?id=$JOB_ID")

    echo "*******************************"
    echo "Response from GET request: $GET_RESPONSE"
    echo "*******************************"
    echo "*******************************"
    echo "Off-chain tasks completed!"
    echo "*******************************" 
}

# Function to handle On-chain option
on_chain() {
    echo "Running On-chain tasks..."

    echo "Installing Snap..."
    sudo apt install -y snap

    echo "Installing Foundry..."
    curl -L https://foundry.paradigm.xyz | bash

    echo "Setting up Foundry..."
    foundryup
    export PATH="$HOME/.foundry/bin:$PATH"
    source ~/.bashrc
    

    echo "Switching to root user..."
    sudo bash -i <<EOF
cd /bin/
echo "Removing existing forge binary..."
rm -f forge
EOF

    echo "Installing Forge dependencies..."
    cd infernet-container-starter/projects/hello-world/contracts
    forge install --no-commit foundry-rs/forge-std
    forge install --no-commit ritual-net/infernet-sdk
    cd ../../../
   
    echo "*******************************"
    echo "Deploying contracts for project hello-world..."
    DEPLOY_OUTPUT=$(make deploy-contracts project=hello-world 2>&1)
    echo "Deployment Output:"
    echo "$DEPLOY_OUTPUT"
   
    echo "*******************************"
    echo "Calling contract for project hello-world..."
    CALL_OUTPUT=$(make call-contract project=hello-world 2>&1)
    echo "Call Contract Output:"
    echo "$CALL_OUTPUT"

    echo "*******************************"
    echo "On-chain tasks completed!"
    echo "*******************************"
}

# Function to handle Node Check
node_check() {
    echo "Checking Infernet Node Logs..."
    NODE_LOGS=$(docker logs infernet-node 2>&1)
    echo "Node Logs:"
    echo "$NODE_LOGS"
}
# Function to handle Payment option
payment() {
    echo "Still in progress. Come back later for it"
    # Add your commands for Payment tasks here
    echo "*******************************"
    echo "Payment tasks completed!"
    echo "*******************************"
}

# Menu for user selection
while true; do
    echo "Select an option:"
    echo "1. Run The Node"
    echo "2. Offchain"
    echo "3. Onchain"
    echo "4. Payment"
    echo "5. Node Run Check"
    echo "6. Exit"

    read -p "Enter your choice [1-6]: " choice

    case $choice in
        1)
            run_the_node
            ;;
        2)
            off_chain
            ;;
        3)
            on_chain
            ;;
        4)
            payment
            ;;
	    5)
            node_check
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done


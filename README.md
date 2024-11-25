
# Ritual Node Setup

Welcome to the Ritual Node Setup repository! This script helps you set up and manage a Ritual Node with options for on-chain, off-chain tasks, payment handling(still working on it not completed), and node monitoring.

I have used https://ritual.academy/nodes/setup/ to code my script. If you need further steps please read the documents.

---

# Before Installation 
Everything is made for 
 **Operating System**: Linux (Ubuntu).

## How to Download and Run

1. Clone the repository:
   ```bash
   git clone https://github.com/akglali/ritual.git ~/temp_repo
   mv ~/temp_repo/* ~/temp_repo/.* ~/ 2>/dev/null
   rm -rf ~/temp_repo

2. Make the script executable:

       chmod +x ritual_node_run.sh 
3. Run the script:
   
       ./ritual_node_run.sh 

## Available Options
When you run the script, you will see the following menu:
 
    Select an option:
    1. Run The Node
    2. Configure Foundry
    3. Exit

## Steps
  ### First "1- Run the Node".
When you run the node it will ask you 3 times  your private key please make sure you enter without any space to make the changes on neccessary files.
  
  
   ### Second, Run the "Configure Foundry". Then exit. 

  Now We need to install forge for that please follow the steps.
    
    cd
    mkdir foundry
    cd foundry
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup
    cd ~/

  Then open a new terminal run:
      
      docker compose -f infernet-container-starter/deploy/docker-compose.yaml down
      docker compose -f infernet-container-starter/deploy/docker-compose.yaml up

Now go back to other terminal
    
    cd infernet-container-starter/

# Important In your wallet (Base Mainnet) should be at least $15.

Now you are ready to deploy your contract

    project=hello-world make deploy-contracts

When you successfully deploy the contract you will see.

![alt text]([http://url/to/img.png](https://github.com/akglali/ritual/blob/main/deploy_contract.png))



Edit your CallContract.s.sol file by inserting the new contract address. The preconfigured address is SaysGM saysGm = SaysGM(0x13D69Cf7d6CE4218F646B759Dcf334D82c023d8e), change it to the address that was generated when calling SaysGM:

    nano ~/infernet-container-starter/projects/hello-world/contracts/script/CallContract.s.sol



The last thing we are going to do is calling the contract  

    project=hello-world make call-contract


# We are all set. Congratulations! 
# Notes
It is important to open a new terminal and watch logs by:

    docker logs -f infernet-anvil

to make sure on-chain works properly.

For the output please check the original documentation https://ritual.academy/nodes/setup/ .


## Contact
For any questions or support:

GitHub: @akglali

Email: akgol97_@hotmail.com

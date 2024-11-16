
# Ritual Node Setup

Welcome to the Ritual Node Setup repository! This script helps you set up and manage a Ritual Node with options for on-chain, off-chain tasks, payment handling(still working on it not completed), and node monitoring.

I have used https://docs.ritual.net/infernet/node/introduction to code my script. If you need further steps please read the documents.

---

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
    1. Off-chain
    2. On-chain
    3. Payment
    4. Node Check
    5. Exit 


# 1-) Offchain
If you run the offchain option more than once please make sure you accept override option that will show.

    
    Adding Docker GPG key and repository...
    File '/usr/share/keyrings/docker-archive-keyring.gpg' exists. Overwrite? (y/N) y


# 2-) Onchain

It is important to open a new terminal and watch logs by:

    docker logs -f infernet-anvil

to make sure on-chain works properly.


## Contact
For any questions or support:

GitHub: @akglali

Email: akgol97_@hotmail.com

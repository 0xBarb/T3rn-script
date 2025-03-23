#!/bin/bash

# Define constants
EXECUTOR_URL="https://github.com/t3rn/executor-release/releases/download/v0.53.1/executor-linux-v0.53.1.tar.gz"
EXECUTOR_FILE="executor-linux-v0.53.1.tar.gz"
EXECUTOR_DIR="executor/executor/bin"
EXECUTOR_BINARY="$EXECUTOR_DIR/executor"
ALCHEMY_API_KEY="XEohpOI_EZagAkTI3pi3sdJ0luvYX-69"
GAS_PRICE="3000"  # Hardcoded gas price in Gwei

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check if executor binary already exists
if [ ! -f "$EXECUTOR_BINARY" ]; then
    # Cleanup old directory if it exists partially
    if [ -d "executor" ]; then
        echo "Removing incomplete executor directory..."
        rm -rf executor || handle_error "Failed to remove incomplete executor directory."
    fi

    # Download the binary
    echo "Downloading the Executor binary from $EXECUTOR_URL..."
    curl -L -o "$EXECUTOR_FILE" "$EXECUTOR_URL" || handle_error "Failed to download the Executor binary. Check your internet connection."

    # Extract the binary
    echo "Extracting the binary..."
    tar -xzvf "$EXECUTOR_FILE" || handle_error "Failed to extract the binary."
    rm -rf "$EXECUTOR_FILE" || handle_error "Failed to remove the downloaded archive."

    # Verify extraction
    if [ ! -f "$EXECUTOR_BINARY" ]; then
        handle_error "Executor binary not found after extraction."
    fi

    echo "Binary downloaded and extracted successfully."
else
    echo "Executor binary already exists. Skipping download and extraction."
fi

# Ensure the binary is executable
chmod +x "$EXECUTOR_BINARY" || handle_error "Failed to make the binary executable."

# Navigate to the binary directory
cd "$EXECUTOR_DIR" || handle_error "Failed to navigate to $EXECUTOR_DIR."

# Request private key from the user
echo -n "Your Private Key without 0x (paste once, it won't be feasible): "
read -s PRIVATE_KEY
echo
if [ -z "$PRIVATE_KEY" ]; then
    handle_error "Private key cannot be empty."
fi

# Set environment variables
export ENVIRONMENT=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
export PRIVATE_KEY_LOCAL="$PRIVATE_KEY"
export EXECUTOR_MAX_L3_GAS_PRICE="$GAS_PRICE"
export ENABLED_NETWORKS="l2rn,arbitrum-sepolia,base-sepolia,blast-sepolia,optimism-sepolia,unichain-sepolia"
export RPC_ENDPOINTS='{
  "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
  "arbt": ["https://arbitrum-sepolia.drpc.org", "https://arb-sepolia.g.alchemy.com/v2/'"$ALCHEMY_API_KEY"'"],
  "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.g.alchemy.com/v2/'"$ALCHEMY_API_KEY"'"],
  "blst": ["https://sepolia.blast.io", "https://blast-sepolia.g.alchemy.com/v2/'"$ALCHEMY_API_KEY"'"],
  "opst": ["https://sepolia.optimism.io", "https://opt-sepolia.g.alchemy.com/v2/'"$ALCHEMY_API_KEY"'"],
  "unit": ["https://unichain-sepolia.drpc.org", "https://unichain-sepolia.g.alchemy.com/v2/'"$ALCHEMY_API_KEY"'"]
}'

# Brief pause before starting
sleep 2
echo "Starting the Executor..."

# Run the executor (this always executes)
./executor || handle_error "Failed to start the Executor."
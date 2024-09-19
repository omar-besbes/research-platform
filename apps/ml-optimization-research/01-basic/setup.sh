#!/bin/bash

# Function to install Python dependencies
install_python_dependencies() {
    # Create a Python virtual environment and install dependencies
    python3 -m venv venv
    venv/bin/pip3 install -r requirements.txt
}

# Function to install Node.js dependencies
install_node_dependencies() {
    # Install Node.js dependencies using pnpm
    pnpm i
}

# Function to download and prepare the dataset
download_dataset() {
    # Download the MNIST dataset using Kaggle API
    venv/bin/kaggle datasets download oddrationale/mnist-in-csv -p dataset --unzip
}

# Function to move the dataset to MinIO
move_dataset_to_minio() {
    # Define MinIO variables
    MINIO_CLI="https://dl.min.io/client/mc/release/linux-amd64/mc"
    MINIO_ACCESS_KEY="minioadmin"
    MINIO_SECRET_KEY="minioadmin"
    MINIO_DESTINATION_BUCKET="data"
    MINIO_SOURCE_DIR="dataset"

    # Download and set up the MinIO client
    curl $MINIO_CLI --create-dirs -o .bin/mc
    chmod +x .bin/mc

    # Get the MinIO endpoint from the Kubernetes node's internal IP
    MINIO_ENDPOINT=http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'):30001

    # Wait until the MinIO deployment is ready and set up the MinIO alias
    until (.bin/mc alias set efrei $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY); do
        echo 'Waiting for deployment "minio" to finish...'
        sleep 1
    done

    # Create the bucket and mirror the dataset to MinIO
    .bin/mc mb efrei/$MINIO_DESTINATION_BUCKET
    .bin/mc mirror --overwrite $MINIO_SOURCE_DIR efrei/$MINIO_DESTINATION_BUCKET
}

# Main script execution
install_python_dependencies
install_node_dependencies
download_dataset
move_dataset_to_minio

# Output completion message and additional instructions
echo "Installation finished!"
echo "You can monitor the state of the cluster by using the Minikube dashboard:"
echo "minikube dashboard"
echo "To run a benchmark, use:"
echo "pnpm start"

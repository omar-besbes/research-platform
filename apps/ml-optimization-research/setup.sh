#!/bin/bash

# Function to delete and create a new Minikube cluster
create_minikube_cluster() {
    # Stop and delete the current Minikube cluster if confirmed by the user
    read -p "Do you want to delete the existing Minikube cluster? (yes/no): " delete_confirmation
    if [[ "$delete_confirmation" == "yes" ]]; then
        minikube delete
    else
        echo "Skipping deletion of the existing Minikube cluster."
    fi

    # Optional user inputs for Minikube resources (default: 8 CPUs, 8GB memory, 40GB disk)
    read -p "Enter the number of CPUs for the new cluster (default: 8): " cpus
    read -p "Enter the amount of memory in GB (default: 8g): " memory
    read -p "Enter the amount of disk in GB (default: 40g): " disk

    # Optional user inputs for Minikube driver (default: kvm2)
    read -p "Enter the driver for the new cluster (default: kvm2): " driver

    # Create a new Minikube cluster with specified or default values
    minikube start --cpus "${cpus:-8}" --memory "${memory:-8g}" --disk-size "${disk:-40g}" --driver "${driver:-kvm2}"
}

# Function to enable necessary addons
enable_minikube_addons() {
    # Enable the metrics-server addon
    minikube addons enable metrics-server

    # Enable ingress (nginx) addon
    minikube addons enable ingress

    # Enable CSI and volume snapshot support
    minikube addons enable volumesnapshots
    minikube addons enable csi-hostpath-driver
}

# Function to apply Kubernetes manifests
apply_manifests() {
    # Apply local Kubernetes manifests
    kubectl apply -k ../../manifests/overlays/local

    # Enable Prometheus for metrics collection
    kubectl apply -k ../../manifests/overlays/local/prometheus
}

# Function to ask the user where to continue installation
continue_installation() {
    echo "Where would you like to continue installation?"
    echo "1. 01-basic"
    
    read -p "Enter your choice (1-x): " choice

    case $choice in
        1)
            cd 01-basic
            bash -c "./setup.sh"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Execute the functions
create_minikube_cluster
enable_minikube_addons
apply_manifests
continue_installation

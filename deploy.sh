#!/bin/bash

k8s_cluster=mycluster
k8s_namespace=myns
helm_name=xm-go

prerequisites(){
    err_message=""
    if ! command -v docker &> /dev/null
    then
        err_message+="\t- docker\n"
    fi
    if ! command -v kubectl &> /dev/null
    then
        err_message+="\t- kubectl\n"
    fi
    if ! command -v k3d &> /dev/null
    then
        err_message+="\t- k3d\n"
    fi

    if [ ! -z "$err_message" ]
    then
        echo "Oh, my very dear user, in order to run this script effectively, you need to have all the requirements installed beforehand!"
        echo -e "Those are:\n$err_message"
        echo "P.S. As a side note, my author was too lazy to include installation of the pre-requisites into the script."
        exit 1
    fi
}

k8s_cluster_preparation(){
    if ! k3d cluster get --no-headers $k8s_cluster &> /dev/null
    then
        k3d cluster create $k8s_cluster
    else
        echo -e "\nThere is a k8s cluster with name $k8s_cluster already running."
        while true; do
            read -p "Do you want me to re-create it? " yn
            case $yn in
                [Yy]* ) echo "Ok, re-creating...";k8s_cluster_cleanup;sleep 1;k8s_cluster_preparation; break;;
                [Nn]* ) echo "Ok, keeping..."; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done

    fi
    kubectl create namespace $k8s_namespace
}

k8s_cluster_cleanup(){
    # helm uninstall $helm_name -n $k8s_namespace &> /dev/null
    k3d cluster delete $k8s_cluster
}

app_deployment(){
    echo -e "\nDeployment of this application can take several minutes. So, please, be patient..."
    helm upgrade --install -n $k8s_namespace --wait $helm_name helm/$helm_name
}

print_info(){
    echo "Starting to deploy $helm_name helm Chart on $k8s_cluster k8s cluster using $k8s_namespace namespace..."
    echo "NOTE: this script has been tested with bash v3.2.57, docker v20.10.22, kubectl v1.25.4 and k3d v5.4.9"
}

prerequisites
print_info
k8s_cluster_preparation
app_deployment

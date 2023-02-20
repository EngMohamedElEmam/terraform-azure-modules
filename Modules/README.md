## Create a service principal to be used with terraform authentication

Azure-CLi

$ az ad sp create-for-rbac --name emam-sp --role "Contributor"

Add the below example to terraform main 

  subscription_id   = ""
  tenant_id         = ""
  client_id         = ""
  client_secret     = ""


# Add User Access Administrator access tp the SPN to grant permission to resources 
$ az role assignment create --assignee --role "User Access Administrator"

#List user roles 
$ az role assignment list --assignee 

#Delete user role 
$ az role assignment delete --assignee --role "Owner"

#grant user role on RG
$ az role assignment create --assignee --role "Reader" 

#Grant IAM Reader to user on RG
az role assignment create --assignee mohamed.elemam@pharma.org --role "Reader" --resource-group "apps"


if you store remote state file in Azure blob storage, you need to create a storage account and a storage container use script remote-state.sh.
Then add script below to local bashrc file to run on startup
#!/bin/bash

export TF_VAR_ARM_CLIENT_SECRET=$(az keyvault secret show --name client-secret --vault-name emamterraform-kv --query value -o tsv)
export TF_VAR_ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name subscription-id --vault-name emamterraform-kv --query value -o tsv)
export TF_VAR_ARM_TENANT_ID=$(az keyvault secret show --name tenant-id --vault-name emamterraform-kv --query value -o tsv)
export TF_VAR_ARM_CLIENT_ID=$(az keyvault secret show --name client-id --vault-name emamterraform-kv --query value -o tsv)
export ARM_ACCESS_KEY=$(az keyvault secret show --name tfstate-storage-key --vault-name emamterraform-kv --query value -o tsv)
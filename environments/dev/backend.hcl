# Used with: terraform init -backend-config=environments/dev/backend.hcl
# Fill in with your actual remote state storage account details, or pass them
# as -backend-config="key=value" flags at init time instead of committing them.

resource_group_name  = "prs-dataeng-cc-infra-rg"   
storage_account_name = "prestodevtfstate"   
container_name         = "tfstate"   
key                     = "dataeng-dev.tfstate"   


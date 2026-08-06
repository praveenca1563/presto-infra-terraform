# Used with: terraform init -backend-config=environments/dev/backend.hcl
# Fill in with your actual remote state storage account details, or pass them
# as -backend-config="key=value" flags at init time instead of committing them.

resource_group_name  = "test-dataeng"    -- need to update 
storage_account_name = "dataengcctest1"   -- need to update  
container_name         = "tfstate"    -- need to update   
key                     = "dev.terraform.tfstate"   -- need to update 

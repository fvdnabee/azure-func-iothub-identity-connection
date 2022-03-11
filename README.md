# Azure Functions: Event/IoT hub function trigger using identity-based connection
This repository is a reproduction for this [azure sdk
issue](https://github.com/Azure/azure-sdk-for-net/issues/27472).

Note: the TF configuration uses [beta resources from the azurerm
provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/3.0-beta).

## Terraform apply
Use iot hub as function app trigger:
```
export ARM_THREEPOINTZERO_BETA_RESOURCES=true
terraform apply -var 'resource_group_name=azure-func-iothub-identity-connection'
```

Switch to eventhub as function app trigger:
```
export ARM_THREEPOINTZERO_BETA_RESOURCES=true
terraform apply -var 'resource_group_name=azure-func-iothub-identity-connection' -var 'consume_iothub=false'
```

## Publish function on provisioned function app:
Get the name of your function from the TF output `funcapp_name` and substitute
it below:
```
cd consumer-func
func azure functionapp publish <output.funcapp_name> --nozip
```

## Send events to Event hub
Set Event hub credentials in `python-eh-send/creds.env`.
```
cd python-eh-send
python -m virtualenv .env
source .env/bin/activate
pip install -r requirements.txt
python send.py
```


## Destroy:
```
terraform destroy -var 'resource_group_name=azure-func-iothub-identity-connection'
```

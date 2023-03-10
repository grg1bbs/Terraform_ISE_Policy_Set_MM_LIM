
terraform {
  required_version = ">= 1.3.9"
  required_providers {
    ciscoise = {
      source  = "CiscoISE/ciscoise"
      version = "0.6.18-beta"
    }
  }
}

provider "ciscoise" {
  username               = "<ERS admin username>"
  password               = "<ERS admin password>"
  base_url               = "https://<ISE PAN IP or FQDN>"
  debug                  = "false"
  ssl_verify             = "false"
  use_api_gateway        = "false"
  use_csrf_token         = "false"
  single_request_timeout = 60
  enable_auto_import     = "false"
}
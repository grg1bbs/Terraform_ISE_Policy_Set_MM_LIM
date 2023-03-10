# Terraform_ISE_Policy_Set_MM_LIM_Wireless
Terraform code for creating Wired Monitor Mode, Wired Low Impact Mode, and Wireless Secure Policy Sets in Cisco Identity Services Engine (ISE) 3.1.
This code is intended to build policy that is common amongst customer ISE deployments. Due to the way the ISE APIs are designed and the inherent limitations, the policies deployed by this code are intended to provide a starting point for a much broader configuration workflow. The Terraform state will likely provide little value for ongoing maintenance and management of the ISE Policies due to current ISE API caveats and limitations.

Separate files were used purposely to separate out the various policy elements in an attempt to make it easier to read and modify the resources being created. If a more monolithic approach is desired, the code can be collapsed into fewer files.

This code was validated using the following:
 - Cisco ISE 3.1 patch 5
 - Terraform version: 1.3.9
 - ISE Terraform provider version: 0.6.18-beta
 
The Cisco ISE Terraform Provider documentation can be found here:

https://registry.terraform.io/providers/CiscoISE/ciscoise/latest/docs

## ISE Pre-requisites
The following ISE configurations are required prior to running this code:

1. An administrator account with the 'ERS Admin' role
2. An Active Directory admin username/password with the permissions necessary to join the ISE nodes to the AD domain
3. The name of the Airespace Access List configured on the WLC to permit access for authorized Wireless sessions

## Policies and Policy Elements created
The following Policy Elements and Policy Sets are created by this code:

### Active Directory
 - AD Join Point created
 - Perform AD join operation for all nodes
 - Search the domain and add the following AD Groups
   - Domain Users
   - Domain Computers

### Policy Elements

 - Allowed Protocols list named 'MAB_EAP-TLS' with the following protocols enabled:
   - Process Host Lookup (MAB)
   - EAP-TLS
 - Certificate Authentication Profile (for EAP-TLS)
 - Identity Source Sequence with CAP & AD
 - Network Device Group (NDG) structure for Monitor Mode & Low Impact Mode
 - Downloadable ACLs and AuthZ Profiles
   - Permissive DACLs (permit ip any any) except for LIM Default (permits DHCP, DNS, and TFTP only)

### Policy Sets

Wired_MM
 - AuthC Policies
   - Dot1x EAP-TLS
   - MAB
 - AuthZ Policies
   - AD User
   - AD Computer
   - Default (updated AuthZ Profile)

Wired_LIM
 - AuthC Policies
   - Dot1x EAP-TLS
   - MAB
 - AuthZ Policies
   - AD User
   - AD Computer
   - Default (updated AuthZ Profile)
   
Wireless_Secure
 - AuthC Policy
   - Dot1x EAP-TLS
 - AuthZ Policies
   - AD User
   - AD Computer

## Policy Set Configuration Example
<img width="1160" alt="Terraform_ISE_Policy_Sets" src="https://user-images.githubusercontent.com/103554967/223611268-56f7beaa-ccd9-4d78-b977-fab9e833d311.png">

## Monitor Mode Policy Set Configuration Example
<img width="1359" alt="Screenshot 2023-03-10 at 4 42 47 pm" src="https://user-images.githubusercontent.com/103554967/224233366-ec6f8a48-7218-4e42-a05c-f04547f02487.png">
<img width="1359" alt="Screenshot 2023-03-10 at 4 43 14 pm" src="https://user-images.githubusercontent.com/103554967/224233489-bb3fa61b-c70c-4dbf-8cac-8f318508289c.png">

## Quick Start
1. Clone this repository:  

    ```bash
    git clone https://github.com/grg1bbs/Terraform_ISE_Policy_Set_MM_LIM
    ```
 
2. Edit the 'variables.tf' file to suit your environment (Active Directory user/password/domain, Corporate SSID name, etc.)

3. Edit the 'terraform.tf' file with the username, password, and base URL values required for your ISE Primary Admin Node (PAN)

4. Initialise, Plan, and Apply the terraform run

    ```bash
    terraform init
    
    terraform plan
    
    terraform apply
    ```
    
### Resulting resources
Unless any errors are found, after the resource build is complete, the resulting status should be:

```diff
+ Apply complete! Resources: 48 added, 0 changed, 0 destroyed.
```

If you check the terraform state, you should see the following resources:
 
```bash
> terraform state list
data.ciscoise_active_directory_get_groups_by_domain_info.domain_computers
data.ciscoise_active_directory_get_groups_by_domain_info.domain_users
data.ciscoise_network_access_authorization_rules.lim_authz_rules
data.ciscoise_network_access_authorization_rules.mm_authz_rules
data.ciscoise_network_access_conditions.wired_dot1x
data.ciscoise_network_access_conditions.wired_mab
data.ciscoise_network_access_conditions.wireless_dot1x
ciscoise_active_directory.corp_ad
ciscoise_active_directory_add_groups.domain_users_computers
ciscoise_active_directory_join_domain_with_all_nodes.corp_ad
ciscoise_allowed_protocols.eaptls
ciscoise_allowed_protocols.mab_eaptls
ciscoise_authorization_profile.authz_wireless_ad_computer
ciscoise_authorization_profile.authz_wireless_ad_user
ciscoise_authorization_profile.lim_authz_ad_computer
ciscoise_authorization_profile.lim_authz_ad_user
ciscoise_authorization_profile.lim_authz_default
ciscoise_authorization_profile.mm_authz_ad_computer
ciscoise_authorization_profile.mm_authz_ad_user
ciscoise_authorization_profile.mm_authz_default
ciscoise_certificate_profile.certprof_ad
ciscoise_downloadable_acl.lim_dacl_ad_computer
ciscoise_downloadable_acl.lim_dacl_ad_user
ciscoise_downloadable_acl.lim_dacl_default
ciscoise_downloadable_acl.mm_dacl_ad_computer
ciscoise_downloadable_acl.mm_dacl_ad_user
ciscoise_downloadable_acl.mm_dacl_default
ciscoise_id_store_sequence.iss_ad_cert
ciscoise_network_access_authentication_rules.authc_wireless_eaptls
ciscoise_network_access_authentication_rules.lim_authc_eaptls
ciscoise_network_access_authentication_rules.lim_authc_mab
ciscoise_network_access_authentication_rules.mm_authc_eaptls
ciscoise_network_access_authentication_rules.mm_authc_mab
ciscoise_network_access_authorization_rules.authz_wireless_ad_computer
ciscoise_network_access_authorization_rules.authz_wireless_ad_user
ciscoise_network_access_authorization_rules.lim_authz_ad_computer
ciscoise_network_access_authorization_rules.lim_authz_ad_user
ciscoise_network_access_authorization_rules.mm_authz_ad_computer
ciscoise_network_access_authorization_rules.mm_authz_ad_user
ciscoise_network_access_authorization_rules_update.lim_authz_default
ciscoise_network_access_authorization_rules_update.mm_authz_default
ciscoise_network_access_policy_set.ps_wired_lim
ciscoise_network_access_policy_set.ps_wired_mm
ciscoise_network_access_policy_set.ps_wireless_secure
ciscoise_network_device_group.ndg_deployment_stage
ciscoise_network_device_group.ndg_lim
ciscoise_network_device_group.ndg_mm
time_sleep.wait_20_seconds
```

### Teardown
To revert all of the configuration that was applied, use 'terraform destroy' and the dependency mappings should ensure everything is destroyed in the correct order.

```bash
> terraform destroy
```

#### Notes
Due to the way the ISE APIs and provider have been designed, the destroy operation will attempt to delete some of the Default Authorization Policies. This will throw an error (as these Default policies cannot be deleted) but the resources used to modify those Policies will be removed from state on the initial destroy operation.

Another error will be seen at the initial destroy due to a current limitation in the ISE APIs. At this time, there is no API DELETE operation for the Certificate Authentication Profile resource. Since the AD Join Point is referenced in the CAP resource, the destroy will throw an error due to the inability to delete the Join Point. 
At this time the only workaround is to delete the Certificate Authentication Profile from the GUI, then run the 'terraform destroy' a second time. This will delete the remaining resources. The following bug has been raised to request the API DELETE operation be provided to address this issue.

https://bst.cloudapps.cisco.com/bugsearch/bug/CSCwe48292


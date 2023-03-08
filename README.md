# * WORK IN PROGRESS *

# Terraform_ISE_Policy_Set_MM_LIM_Wireless
Terraform code for creating Wired Monitor Mode, Wired Low Impact Mode, and Wireless Secure Policy Sets in Cisco Identity Services Engine (ISE) 3.1

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


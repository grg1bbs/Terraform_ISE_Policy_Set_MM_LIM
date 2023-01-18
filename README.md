# * WORK IN PROGRESS *

# Terraform_ISE_Policy_Set_MM_LIM
Terraform code for creating Wired Monitor Mode &amp; Low Impact Mode Policy Sets in Cisco Identity Services Engine (ISE) 3.1

This code was validated using the following:
 - Cisco ISE 3.1 patch 5
 - Terraform version: 1.3.5
 - ISE Terraform provider version: 0.6.11-beta
 
The Cisco ISE Terraform Provider documentation can be found here:

https://registry.terraform.io/providers/CiscoISE/ciscoise/latest/docs

## ISE Pre-requisites
The following ISE configurations are required prior to running this code:

1. An administrator account with the 'ERS Admin' role

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
   - Default (updated AuthZ Profile)  <-- BUG OPEN

Wired_LIM
 - AuthC Policies
   - Dot1x EAP-TLS
   - MAB
 - AuthZ Policies
   - AD User
   - AD Computer
   - Default (updated AuthZ Profile) <-- BUG OPEN

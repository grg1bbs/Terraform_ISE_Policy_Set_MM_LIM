## The AD admin username/password variables can also be referenced by standard options like local environment variables, *.tfvars file, etc.

variable "ad_admin_name" {
  default   = "<AD admin username>"
  description = "AD Domain username used to join ISE to the domain"
  sensitive = true
}

variable "ad_admin_password" {
  default   = "<AD admin password>"
  description = "AD Domain password used to join ISE to the domain"
  sensitive = true
}

variable "domain_name" {
  default = "<AD domain name>"
  description = "AD Domain name used when joining ISE to the domain"
}

variable "join_point_name" {
  default   = "CORP-AD"
  description = "Name defined for the Active Directory Join Point in ISE"
  sensitive = true
}

variable "ps_wired_mm_name" {
  default = "Wired_MM"
  description = "Name defined for the Wired Monitor Mode Policy Set"
}

variable "ps_wired_lim_name" {
  default = "Wired_LIM"
  description = "Name defined for the Wired Low Impact Mode Policy Set"
}

variable "authc_policy_eaptls" {
  default = "Dot1x EAP-TLS"
  description = "Name defined for the 802.1x EAP-TLS Authentication Policy for all Policy Sets"
}

variable "authz_policy_ad_user" {
  default = "AD User"
  description = "Name defined for the AD User Authorization Policy for all Policy Sets"
}

variable "authz_policy_ad_computer" {
  default = "AD Computer"
  description = "Name defined for the AD Computer Authorization Policy for all Policy Sets"
}

variable "authc_policy_mab" {
  default = "MAB"
  description = "Name defined for the MAB Authentication Policy for the Wired Policy Sets"
}

variable "corp_wireless_ssid" {
  default = "<:SSID>"
  description = "Name of the Corporate secure SSID, including the preceding colon (:) used as a matching condtion for the Corp Wireless Policy Set"
}

variable "ps_corp_wireless_name" {
  default = "Wireless_Secure"
  description = "Name defined for the Corporate Wireless Policy Set"
}

variable "wireless_acl_name" {
  default = "ACL_ALLOW_ALL"
  description = "Airespace ACL name defined in the Wireless Authorization Profiles; must be pre-configured on the WLC"
}
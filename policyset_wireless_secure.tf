## Get the id for the built-in condition - Wireless_802.1X

data "ciscoise_network_access_conditions" "wireless_dot1x" {
  provider = ciscoise
  name     = "Wireless_802.1X"
}

## Create Policy Set for Corp Wireless

resource "ciscoise_network_access_policy_set" "ps_wireless_secure" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wired_mm,
    ciscoise_network_access_policy_set.ps_wired_lim
  ]
  parameters {
    default      = "false"
    name         = var.ps_corp_wireless_name
    description  = "Corp Wireless"
    rank         = 2
    is_proxy     = "false"
    service_name = "EAP-TLS"
    state        = "enabled"
    condition {
      condition_type = "ConditionAndBlock"
      is_negate      = "false"
      children {
        condition_type = "ConditionReference"
        is_negate      = "false"
        id = data.ciscoise_network_access_conditions.wireless_dot1x.item_name[0].id
      }
      children {
        condition_type  = "ConditionAttributes"
        is_negate       = "false"
        dictionary_name = "Radius"
        attribute_name  = "Called-Station-ID"
        operator        = "endsWith"
        attribute_value = var.corp_wireless_ssid
      }
    }
  }
}

## Create Corp Wireless AuthC Policy - Dot1x EAP-TLS

resource "ciscoise_network_access_authentication_rules" "authc_wireless_eaptls" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wireless_secure
  ]
  parameters {
    identity_source_name = ciscoise_id_store_sequence.iss_ad_cert.item[0].name
    if_auth_fail         = "REJECT"
    if_process_fail      = "DROP"
    if_user_not_found    = "REJECT"
    policy_id            = ciscoise_network_access_policy_set.ps_wireless_secure.parameters[0].id
    rule {
      default = "false"
      name    = var.authc_policy_eaptls
      rank    = 0
      state   = "enabled"
      condition {
        condition_type = "ConditionAndBlock"
        is_negate      = "false"
        children {
          condition_type = "ConditionReference"
          is_negate      = "false"
          id = data.ciscoise_network_access_conditions.wireless_dot1x.item_name[0].id
        }
        children {
          condition_type  = "ConditionAttributes"
          dictionary_name = "Network Access"
          attribute_name  = "EapAuthentication"
          operator        = "equals"
          attribute_value = "EAP-TLS"
          is_negate       = "false"
        }
      }
    }
  }
}

## Create Corp Wireless AuthC Policy Rule 1 - AD User

resource "ciscoise_network_access_authorization_rules" "authz_wireless_ad_user" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wireless_secure,
    ciscoise_active_directory_add_groups.domain_users_computers
  ]
  parameters {
    policy_id = ciscoise_network_access_policy_set.ps_wireless_secure.parameters[0].id
    profile = [
      ciscoise_authorization_profile.authz_wireless_ad_user.item[0].name
    ]
    rule {
      default = "false"
      name    = var.authz_policy_ad_user
      rank    = 0
      state   = "enabled"
      condition {
        condition_type = "ConditionAndBlock"
        is_negate      = "false"
        children {
          condition_type = "ConditionReference"
          is_negate      = "false"
          id = data.ciscoise_network_access_conditions.wireless_dot1x.item_name[0].id
        }
        children {
          condition_type  = "ConditionAttributes"
          dictionary_name = ciscoise_active_directory.corp_ad.item[0].name
          attribute_name  = "ExternalGroups"
          operator        = "equals"
          attribute_value = data.ciscoise_active_directory_get_groups_by_domain_info.domain_users.item[0].groups[0].name
          is_negate       = "false"
        }
      }
    }
  }
}

## Create Wired_MM AuthZ Policy Rule 2 - AD Computer

resource "ciscoise_network_access_authorization_rules" "authz_wireless_ad_computer" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wireless_secure,
    ciscoise_network_access_authorization_rules.authz_wireless_ad_user
  ]
  parameters {
    policy_id = ciscoise_network_access_policy_set.ps_wireless_secure.parameters[0].id
    profile = [
      ciscoise_authorization_profile.authz_wireless_ad_computer.item[0].name,
    ]
    rule {
      default = "false"
      name    = var.authz_policy_ad_computer
      rank    = 1
      state   = "enabled"
      condition {
        condition_type = "ConditionAndBlock"
        is_negate      = "false"
        children {
          condition_type = "ConditionReference"
          is_negate      = "false"
          id = data.ciscoise_network_access_conditions.wireless_dot1x.item_name[0].id
        }
        children {
          condition_type  = "ConditionAttributes"
          dictionary_name = ciscoise_active_directory.corp_ad.item[0].name
          attribute_name  = "ExternalGroups"
          operator        = "equals"
          attribute_value = data.ciscoise_active_directory_get_groups_by_domain_info.domain_computers.item[0].groups[0].name
          is_negate       = "false"
        }
      }
    }
  }
}

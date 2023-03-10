## Issue a 20 second sleep timer before creating the Wired_MM Policy Set.
## This is necessary to mitigate a race condition with the creation of the Monitor Mode Network Device Group (NDG)

resource "time_sleep" "wait_20_seconds" {
  depends_on = [
    ciscoise_active_directory.corp_ad,
    ciscoise_network_device_group.ndg_deployment_stage,
    ciscoise_network_device_group.ndg_mm,
    ciscoise_network_device_group.ndg_lim
  ]
  create_duration = "20s"
}

## Create the Policy Set for Wired Monitor Mode

resource "ciscoise_network_access_policy_set" "ps_wired_mm" {
  provider = ciscoise
  depends_on = [
    time_sleep.wait_20_seconds,
    ciscoise_allowed_protocols.mab_eaptls,
    ciscoise_network_device_group.ndg_deployment_stage,
    ciscoise_network_device_group.ndg_mm,
    ciscoise_network_device_group.ndg_lim
  ]
  parameters {
    default      = "false"
    name         = var.ps_wired_mm_name
    description  = "Wired Monitor Mode"
    rank         = 0
    is_proxy     = "false"
    service_name = ciscoise_allowed_protocols.mab_eaptls.item[0].name
    state        = "enabled"
    condition {
      condition_type = "ConditionAndBlock"
      is_negate      = "false"
      children {
        condition_type  = "ConditionAttributes"
        is_negate       = "false"
        dictionary_name = "Radius"
        attribute_name  = "NAS-Port-Type"
        operator        = "equals"
        attribute_value = "Ethernet"
      }
      children {
        condition_type  = "ConditionAttributes"
        is_negate       = "false"
        dictionary_name = "DEVICE"
        attribute_name  = ciscoise_network_device_group.ndg_deployment_stage.item[0].ndgtype
        operator        = "equals"
        attribute_value = "Deployment Stage#Monitor Mode"
      }
    }
  }
}

## Get id for built-in Condition - Wired_802.1X

data "ciscoise_network_access_conditions" "wired_dot1x" {
  provider = ciscoise
  name     = "Wired_802.1X"
}

## Get id for build-in Condition - Wired_MAB
data "ciscoise_network_access_conditions" "wired_mab" {
  provider = ciscoise
  name     = "Wired_MAB"
}

## Create Wired_MM AuthC Policy - Dot1x EAP-TLS

resource "ciscoise_network_access_authentication_rules" "mm_authc_eaptls" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wired_mm
  ]
  parameters {
    identity_source_name = ciscoise_id_store_sequence.iss_ad_cert.item[0].name
    if_auth_fail         = "REJECT"
    if_process_fail      = "DROP"
    if_user_not_found    = "REJECT"
    policy_id            = ciscoise_network_access_policy_set.ps_wired_mm.parameters[0].id
    rule {
      default = "false"
      name    = var.authc_policy_eaptls
      rank    = 0
      state   = "enabled"
      condition {
        condition_type = "ConditionReference"
        is_negate      = "false"
        id = data.ciscoise_network_access_conditions.wired_mab.item_name[0].id
      }
    }
  }
}

## Create Wired_MM AuthC Policy - MAB

resource "ciscoise_network_access_authentication_rules" "mm_authc_mab" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wired_mm,
    ciscoise_network_access_authentication_rules.mm_authc_eaptls
  ]
  parameters {
    identity_source_name = "Internal Endpoints"
    if_auth_fail         = "REJECT"
    if_process_fail      = "DROP"
    if_user_not_found    = "CONTINUE"
    policy_id            = ciscoise_network_access_policy_set.ps_wired_mm.parameters[0].id
    rule {
      default = "false"
      name    = var.authc_policy_mab
      rank    = 1
      state   = "enabled"
      condition {
        condition_type = "ConditionReference"
        is_negate      = "false"
        id = data.ciscoise_network_access_conditions.wired_mab.item_name[0].id
      }
    }
  }
}

## Create Wired_MM AuthZ Policy Rule 1 - AD User

resource "ciscoise_network_access_authorization_rules" "mm_authz_ad_user" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_policy_set.ps_wired_mm,
    ciscoise_active_directory_add_groups.domain_users_computers
  ]
  parameters {
    policy_id = ciscoise_network_access_policy_set.ps_wired_mm.parameters[0].id
    profile = [
      ciscoise_authorization_profile.mm_authz_ad_user.item[0].name,
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
          condition_type  = "ConditionAttributes"
          dictionary_name = "Network Access"
          attribute_name  = "EapAuthentication"
          operator        = "equals"
          attribute_value = "EAP-TLS"
          is_negate       = "false"
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

resource "ciscoise_network_access_authorization_rules" "mm_authz_ad_computer" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_authorization_rules.mm_authz_ad_user,
    ciscoise_network_access_policy_set.ps_wired_mm
  ]
  parameters {
    policy_id = ciscoise_network_access_policy_set.ps_wired_mm.parameters[0].id
    profile = [
      ciscoise_authorization_profile.mm_authz_ad_computer.item[0].name,
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
          condition_type  = "ConditionAttributes"
          dictionary_name = "Network Access"
          attribute_name  = "EapAuthentication"
          operator        = "equals"
          attribute_value = "EAP-TLS"
          is_negate       = "false"
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

## Update Wired_MM Default AuthZ Policy Rule to replace 'DenyAccess' with 'MM-AuthZ-Default' AuthZ Profile -- BUG OPEN

data "ciscoise_network_access_authorization_rules" "mm_authz_rules" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_authorization_rules.mm_authz_ad_user,
    ciscoise_network_access_authorization_rules.mm_authz_ad_computer
  ]
  policy_id = ciscoise_network_access_policy_set.ps_wired_mm.parameters[0].id
}

resource "ciscoise_network_access_authorization_rules_update" "mm_authz_default" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_access_authorization_rules.mm_authz_ad_user,
    ciscoise_network_access_authorization_rules.mm_authz_ad_computer
  ]
  parameters {
    policy_id = ciscoise_network_access_policy_set.ps_wired_mm.parameters[0].id
    id        = data.ciscoise_network_access_authorization_rules.mm_authz_rules.items[2].rule[0].id
    profile = [
      "MM-AuthZ-Default"
    ]
    rule {
      name    = "Default"
      rank    = 2
      state   = "enabled"
      default = true
    }
  }
}

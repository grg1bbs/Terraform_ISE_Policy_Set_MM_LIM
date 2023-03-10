## Create Allowed Protocols Lists

resource "ciscoise_allowed_protocols" "mab_eaptls" {
  provider = ciscoise
  parameters {
    name                         = "MAB_EAP-TLS"
    description                  = ""
    process_host_lookup          = "true"
    allow_pap_ascii              = "false"
    allow_chap                   = "false"
    allow_ms_chap_v1             = "false"
    allow_ms_chap_v2             = "false"
    allow_eap_md5                = "false"
    allow_eap_tls                = "true"
    allow_leap                   = "false"
    allow_peap                   = "false"
    allow_eap_fast               = "false"
    allow_eap_ttls               = "false"
    allow_teap                   = "false"
    allow_preferred_eap_protocol = "false"
    eap_tls_l_bit                = "false"
    allow_weak_ciphers_for_eap   = "false"
    require_message_auth         = "false"
    eap_tls {
      allow_eap_tls_auth_of_expired_certs     = "false"
      eap_tls_enable_stateless_session_resume = "true"
      eap_tls_session_ticket_precentage       = 10
      eap_tls_session_ticket_ttl              = 2
      eap_tls_session_ticket_ttl_units        = "HOURS"
    }
  }
}

resource "ciscoise_allowed_protocols" "eaptls" {
  provider = ciscoise
  parameters {
    name                         = "EAP-TLS"
    description                  = ""
    process_host_lookup          = "false"
    allow_pap_ascii              = "false"
    allow_chap                   = "false"
    allow_ms_chap_v1             = "false"
    allow_ms_chap_v2             = "false"
    allow_eap_md5                = "false"
    allow_eap_tls                = "true"
    allow_leap                   = "false"
    allow_peap                   = "false"
    allow_eap_fast               = "false"
    allow_eap_ttls               = "false"
    allow_teap                   = "false"
    allow_preferred_eap_protocol = "false"
    eap_tls_l_bit                = "false"
    allow_weak_ciphers_for_eap   = "false"
    require_message_auth         = "false"
    eap_tls {
      allow_eap_tls_auth_of_expired_certs     = "false"
      eap_tls_enable_stateless_session_resume = "true"
      eap_tls_session_ticket_precentage       = 10
      eap_tls_session_ticket_ttl              = 2
      eap_tls_session_ticket_ttl_units        = "HOURS"
    }
  }
}

## Create a Certificate Authentication Profile (CAP)

resource "ciscoise_certificate_profile" "certprof_ad" {
  provider = ciscoise
  depends_on = [
    ciscoise_active_directory.corp_ad
  ]
  parameters {
    allowed_as_user_name         = "false"
    certificate_attribute_name   = "SUBJECT_COMMON_NAME"
    description                  = "AD Cert Profile"
    external_identity_store_name = var.join_point_name
    match_mode                   = "RESOLVE_IDENTITY_AMBIGUITY"
    name                         = "CertProf_AD"
    username_from                = "CERTIFICATE"
  }
}

## Create an Identity Source Sequence using the CAP and AD Join Point

resource "ciscoise_id_store_sequence" "iss_ad_cert" {
  provider = ciscoise
  parameters {
    break_on_store_fail                = "false"
    certificate_authentication_profile = ciscoise_certificate_profile.certprof_ad.parameters[0].name
    description                        = ""
    id_seq_item {

      idstore = var.join_point_name
      order   = 1
    }
    name = "ISS_AD_Cert"
  }
}

# Create Network Device Groups for Monitor Mode & Low Impact Mode

resource "ciscoise_network_device_group" "ndg_deployment_stage" {
  provider = ciscoise
  parameters {
    description = "Root Deployment Stage NDG"
    name        = "Deployment Stage#Deployment Stage"
    ndgtype     = "Deployment Stage"
  }
}

resource "ciscoise_network_device_group" "ndg_mm" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_device_group.ndg_deployment_stage
  ]
  parameters {
    description = "Monitor Mode NDG"
    name        = "Deployment Stage#Deployment Stage#Monitor Mode"
    ndgtype     = ciscoise_network_device_group.ndg_deployment_stage.item[0].ndgtype
  }
}

resource "ciscoise_network_device_group" "ndg_lim" {
  provider = ciscoise
  depends_on = [
    ciscoise_network_device_group.ndg_deployment_stage,
    ciscoise_network_device_group.ndg_mm,
  ]
  parameters {
    description = "Low Impact Mode NDG"
    name        = "Deployment Stage#Deployment Stage#Low Impact Mode"
    ndgtype     = ciscoise_network_device_group.ndg_deployment_stage.item[0].ndgtype
  }
}

# Create DACLs

resource "ciscoise_downloadable_acl" "mm_dacl_ad_computer" {
  provider = ciscoise
  parameters {
    dacl        = "permit ip any any"
    dacl_type   = "IPV4"
    description = ""
    name        = "MM-DACL-AD-Computer"
  }
}
resource "ciscoise_downloadable_acl" "mm_dacl_ad_user" {
  provider = ciscoise
  parameters {
    dacl        = "permit ip any any"
    dacl_type   = "IPV4"
    description = ""
    name        = "MM-DACL-AD-User"
  }
}

resource "ciscoise_downloadable_acl" "mm_dacl_default" {
  provider = ciscoise
  parameters {
    dacl        = "permit ip any any"
    dacl_type   = "IPV4"
    description = ""
    name        = "MM-DACL-Default"
  }
}
resource "ciscoise_downloadable_acl" "lim_dacl_ad_computer" {
  provider = ciscoise
  parameters {
    dacl        = "permit ip any any"
    dacl_type   = "IPV4"
    description = ""
    name        = "LIM-DACL-AD-Computer"
  }
}
resource "ciscoise_downloadable_acl" "lim_dacl_ad_user" {
  provider = ciscoise
  parameters {
    dacl        = "permit ip any any"
    dacl_type   = "IPV4"
    description = ""
    name        = "LIM-DACL-AD-User"
  }
}
resource "ciscoise_downloadable_acl" "lim_dacl_default" {
  provider = ciscoise
  parameters {
    dacl        = "permit udp any eq bootpc any eq bootps\npermit udp any any eq domain\npermit udp any any eq tftp\ndeny ip any any"
    dacl_type   = "IPV4"
    description = ""
    name        = "LIM-DACL-Default"
  }
}

## Create Authorization Profiles

resource "ciscoise_authorization_profile" "mm_authz_ad_computer" {
  provider = ciscoise
  parameters {
    name                        = "MM-AuthZ-AD-Computer"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    dacl_name                   = ciscoise_downloadable_acl.mm_dacl_ad_computer.item[0].name
  }
}

resource "ciscoise_authorization_profile" "mm_authz_ad_user" {
  provider = ciscoise
  parameters {
    name                        = "MM-AuthZ-AD-User"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    dacl_name                   = ciscoise_downloadable_acl.mm_dacl_ad_user.item[0].name
  }
}

resource "ciscoise_authorization_profile" "mm_authz_default" {
  provider = ciscoise
  parameters {
    name                        = "MM-AuthZ-Default"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    dacl_name                   = ciscoise_downloadable_acl.mm_dacl_default.item[0].name
  }
}
resource "ciscoise_authorization_profile" "lim_authz_ad_computer" {
  provider = ciscoise
  parameters {
    name                        = "LIM-AuthZ-AD-Computer"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    dacl_name                   = ciscoise_downloadable_acl.lim_dacl_ad_computer.item[0].name
  }
}
resource "ciscoise_authorization_profile" "lim_authz_ad_user" {
  provider = ciscoise
  parameters {
    name                        = "LIM-AuthZ-AD-User"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    dacl_name                   = ciscoise_downloadable_acl.lim_dacl_ad_user.item[0].name
  }
}
resource "ciscoise_authorization_profile" "lim_authz_default" {
  provider = ciscoise
  parameters {
    name                        = "LIM-AuthZ-Default"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    dacl_name                   = ciscoise_downloadable_acl.lim_dacl_default.item[0].name
  }
}

resource "ciscoise_authorization_profile" "authz_wireless_ad_computer" {
  provider = ciscoise
  parameters {
    name                        = "AuthZ-Wireless-AD-Computer"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    airespace_acl               = var.wireless_acl_name
  }
}

resource "ciscoise_authorization_profile" "authz_wireless_ad_user" {
  provider = ciscoise
  parameters {
    name                        = "AuthZ-Wireless-AD-User"
    description                 = ""
    access_type                 = "ACCESS_ACCEPT"
    profile_name                = "Cisco"
    authz_profile_type          = "SWITCH"
    service_template            = "false"
    track_movement              = "false"
    agentless_posture           = "false"
    easywired_session_candidate = "false"
    airespace_acl               = var.wireless_acl_name
  }
}

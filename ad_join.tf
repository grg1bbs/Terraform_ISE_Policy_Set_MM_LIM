## Create Active Directory Join Point

resource "ciscoise_active_directory" "corp_ad" {
  provider = ciscoise
  parameters {
    ad_scopes_names = "Default_Scope"
    adgroups {}
    description = ""
    domain      = var.domain_name
    name        = var.join_point_name
  }
}

## Join the node(s) to the AD Domain

resource "ciscoise_active_directory_join_domain_with_all_nodes" "corp_ad" {
  provider = ciscoise
  lifecycle {
    create_before_destroy = true
  }
  parameters {
    id = ciscoise_active_directory.corp_ad.parameters[0].id
    additional_data {

      name  = "username"
      value = var.ad_admin_name
    }
    additional_data {

      name  = "password"
      value = var.ad_admin_password
    }
  }
}

## Search AD domain join point for groups to capture the name, SID, and type values

data "ciscoise_active_directory_get_groups_by_domain_info" "domain_computers" {
  provider = ciscoise
  depends_on = [
    ciscoise_active_directory_join_domain_with_all_nodes.corp_ad
  ]
  id = ciscoise_active_directory.corp_ad.parameters[0].id
  additional_data {

    name  = "domain"
    value = var.domain_name
  }
  additional_data {

    name  = "filter"
    value = "*Domain Computers"
  }
}
data "ciscoise_active_directory_get_groups_by_domain_info" "domain_users" {
  provider = ciscoise
  depends_on = [
    ciscoise_active_directory_join_domain_with_all_nodes.corp_ad
  ]
  id = ciscoise_active_directory.corp_ad.parameters[0].id
  additional_data {

    name  = "domain"
    value = var.domain_name
  }
  additional_data {

    name  = "filter"
    value = "*Domain Users"
  }
}

## Add AD Groups

resource "ciscoise_active_directory_add_groups" "domain_users_computers" {
  provider = ciscoise
  parameters {
    adgroups {
      groups {
        name = data.ciscoise_active_directory_get_groups_by_domain_info.domain_computers.item[0].groups[0].name
        sid  = data.ciscoise_active_directory_get_groups_by_domain_info.domain_computers.item[0].groups[0].sid
        type = data.ciscoise_active_directory_get_groups_by_domain_info.domain_computers.item[0].groups[0].type
      }
      groups {
        name = data.ciscoise_active_directory_get_groups_by_domain_info.domain_users.item[0].groups[0].name
        sid  = data.ciscoise_active_directory_get_groups_by_domain_info.domain_users.item[0].groups[0].sid
        type = data.ciscoise_active_directory_get_groups_by_domain_info.domain_users.item[0].groups[0].type
      }
    }
    description = ""
    domain      = var.domain_name
    name        = var.join_point_name
    id          = ciscoise_active_directory.corp_ad.parameters[0].id
  }
}
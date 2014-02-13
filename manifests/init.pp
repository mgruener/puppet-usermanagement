class usermanagement (
  $users = hiera_hash("${module_name}::users"),
  $groups = hiera_hash("${module_name}::groups"),
  $usermaps = hiera_array("${module_name}::localusers",undef),
  $groupmaps = hiera_array("${module_name}::localgroups",undef)
) {

  if $users {
    if $usermaps {
      # create virtual resources from _all_ user data found
      # in the hiera data
      create_resources("@${module_name}::user",$users)

      # from the virtual resources created above, realize all
      # users that belong on this system
      realize Usermanagement::User[$usermaps]
    }
    else {
      # no user mappings given, create all users found in the hiera data
      create_resources("${module_name}::user",$users)
    }
  }
  else {
    notice('No users found')
  }

  if $groups {
    if $groupmaps {
      # create virtual resources from _all_ group data found
      # in the hiera data
      create_resources('@group',$groups)

      # from the virtual resources created above, realize all
      # groups that belong on this system
      realize Group[$groupmaps]
    }
    else {
      # no group mappings given, create all groups found in the hiera data
      create_resources('group',$groups)
    }
  }
  else {
    notice('No groups found')
  }

  file { '/etc/sudoers':
    ensure => present,
    owner  => root,
    mode   => '0440',
    source => "puppet:///modules/${module_name}/sudoers"
  }
}

class usermanagement ($users = hiera_hash('users'),
                      $groups = hiera_hash('groups'),
                      $usermaps = hiera_hash('localusers',undef),
                      $groupmaps = hiera_hash('localgroups',undef)){

  if $usermaps {
    # create virtual resources from _all_ user data found
    # in the hiera data
    create_resources('@usermanagement::user',hiera_hash('users'))

    # from the virtual resources created above, realize all
    # users that belong on this system
    realize Usermanagement::User[hiera_array('localusers')]
  }
  else {
    # no user mappings given, create all users found in the hiera data
    create_resources('usermanagement::user',hiera_hash('users'))
  }

  if $groupmaps {
    # create virtual resources from _all_ group data found
    # in the hiera data
    create_resources('@group',hiera_hash('groups'))

    # from the virtual resources created above, realize all
    # groups that belong on this system
    realize Group[hiera_array('localgroups')]
  }
  else {
    # no group mappings given, create all groups found in the hiera data
    create_resources('group',hiera_hash('groups'))
  }

  file { '/etc/sudoers':
    ensure => present,
    owner  => root,
    mode   => '0440',
    source => "puppet:///modules/${module_name}/sudoers"
  }
}

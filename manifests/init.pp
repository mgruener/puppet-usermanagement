class usermanagement (
  $users = undef,
  $groups = undef,
  $userdefaults = undef,
  $groupdefaults = undef,
  $usermaps = undef,
  $groupmaps = undef,
  $install_sudoers = true,
  $hiera_merge = false,
) {

  $myclass = $module_name

  case type($hiera_merge) {
    'string': {
      validate_re($hiera_merge, '^(true|false)$', "${myclass}::hiera_merge may be either 'true' or 'false' and is set to <${hiera_merge}>.")
      $hiera_merge_real = str2bool($hiera_merge)
    }
    'boolean': {
      $hiera_merge_real = $hiera_merge
    }
    default: {
      fail("${myclass}::hiera_merge type must be true or false.")
    }
  }

  case type($install_sudoers) {
    'string': {
      validate_re($install_sudoers, '^(true|false)$', "${myclass}::install_sudoers may be either 'true' or 'false' and is set to <${install_sudoers}>.")
      $install_sudoers_real = str2bool($install_sudoers)
    }
    'boolean': {
      $install_sudoers_real = $install_sudoers
    }
    default: {
      fail("${myclass}::install_sudoers type must be true or false.")
    }
  }

  if $userdefaults != undef {
    if !is_hash($userdefaults) {
        fail("${myclass}::userdefaults must be a hash.")
    }

    if $hiera_merge_real == true {
      $userdefaults_real = hiera_hash("${myclass}::userdefaults",{})
    } else {
      $userdefaults_real = $userdefaults
    }
  } else {
    $userdefaults_real = {}
  }

  if $groupdefaults != undef {
    if !is_hash($groupdefaults) {
        fail("${myclass}::groupdefaults must be a hash.")
    }

    if $hiera_merge_real == true {
      $groupdefaults_real = hiera_hash("${myclass}::groupdefaults",{})
    } else {
      $groupdefaults_real = $groupdefaults
    }
  } else {
    $groupdefaults_real = {}
  }

  if $users != undef {
    if !is_hash($users) {
        fail("${myclass}::users must be a hash.")
    }

    if $hiera_merge_real == true {
      $users_real = hiera_hash("${myclass}::users",undef)
    } else {
      $users_real = $users
    }

    if $usermaps {
      if !is_hash($usermaps) {
          fail("${myclass}::usermaps must be a hash.")
      }

      if $hiera_merge_real == true {
        $usermaps_real = hiera_hash("${myclass}::localusers",undef)
      } else {
        $usermaps_real = $usermaps
      }

      # create virtual resources from _all_ user data found
      # in the hiera data
      create_resources("@${myclass}::user",$users_real,$userdefaults_real)

      # from the virtual resources created above, realize all
      # users that belong on this system
      realize Usermanagement::User[$usermaps_real]
    }
    else {
      # no user mappings given, create all users found in the hiera data
      create_resources("${myclass}::user",$users_real,$userdefaults_real)
    }
  }
  else {
    notice('No users found')
  }

  if $groups != undef {
    if !is_hash($groups) {
        fail("${myclass}::groups must be a hash.")
    }

    if $hiera_merge_real == true {
      $groups_real = hiera_hash("${myclass}::groups",undef)
    } else {
      $groups_real = $groups
    }

    if $groupmaps != undef {
      if !is_hash($groupmaps) {
          fail("${myclass}::groupmaps must be a hash.")
      }

      if $hiera_merge_real == true {
        $groupmaps_real = hiera_hash("${myclass}::localgroups",undef)
      } else {
        $groupmaps_real = $groupmaps
      }

      # create virtual resources from _all_ group data found
      # in the hiera data
      create_resources('@group',$groups_real,$groupdefaults_real)

      # from the virtual resources created above, realize all
      # groups that belong on this system
      realize Group[$groupmaps]
    }
    else {
      # no group mappings given, create all groups found in the hiera data
      create_resources('group',$groups_real,$groupdefaults_real)
    }
  }
  else {
    notice('No groups found')
  }

  if $install_sudoers_real {
    file { '/etc/sudoers':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0440',
      source => "puppet:///modules/${myclass}/sudoers"
    }
  }
}

define usermanagement::user ( $ensure = present,
                              $comment = undef,
                              $managehome = false,
                              $home = "/home/${name}",
                              $password = undef,
                              $uid = undef,
                              $gid = undef,
                              $shell = undef,
                              $groups = undef,
                              $sshkey = $title) {

  case $ensure {
    present => {  $dir_ensure = directory
                  $file_ensure = file
    }
    absent  => {  $dir_ensure = absent
                  $file_ensure = absent
    }
    default => {  err("${ensure} is not a valid value for \$ensure!")
                  fail()
    }
  }

  user { $title:
    ensure     => $ensure,
    name       => $name,
    comment    => $comment,
    managehome => $managehome,
    home       => $home,
    password   => $password,
    uid        => $uid,
    gid        => $gid,
    shell      => $shell,
    groups     => $groups,
  }

  # during creation: first the group, then the user
  # during deletion: first the user, then the group
  # but only if the user has an explizit group assigned
  if $gid {
    if $ensure == present {
      Group[$gid] -> User[$title]
    }
    else {
      User[$title] -> Group[$gid]
    }
  }

  # yes, I know, don't ask
  if $sshkey {

    file { "${home}/.ssh":
      ensure  => $dir_ensure,
      owner   => $name,
      force   => true,
      recurse => true,
      mode    => '0700',
      require => User[$title],
    }

    file { "${home}/.ssh/authorized_keys":
      ensure  => $file_ensure
      owner   => $name,
      source  => "puppet:///modules/${module_name}/sshkeys/${sshkey}",
      mode    => '0600',
      require => File["${home}/.ssh/"],
    }
  }
}

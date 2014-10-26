define usermanagement::user (
  $ensure = present,
  $comment = undef,
  $managehome = false,
  $home = "/home/${name}",
  $password = undef,
  $uid = undef,
  $gid = undef,
  $shell = undef,
  $groups = undef,
  $sshkeyfilepath = "${module_name}/sshkeys",
  $sshkeyfile = $title
) {

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

  if $sshkeyfile {
    $sshkeydata = chomp(split(file("${sshkeyfilepath}/${sshkeyfile}"),' '))

    ssh_authorized_key { $title:
      name   => "${name}-${sshkeydata[2]}",
      ensure => $ensure,
      key    => $sshkeydata[1],
      type   => $sshkeydata[0],
      user   => $name
    }
  }
}

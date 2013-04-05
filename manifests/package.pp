class drbd::package {
  if $drbd::ensure == 'present' {
    $package_ensure = $drbd::auto_upgrade ? {
      true  => 'latest',
      false => 'installed',
    }
  } else {
    $package_ensure = 'purged'
  }

  package {$drbd::package:
    ensure  => $package_ensure,
  }

  if ($operatingsystem == 'ubuntu') {
    package { 'linux-server':
       ensure  => present,
       require => Package[$drbd::package],
    }
    package { 'linux-virtual':
       ensure  => purged,
       require => Package['linux-server'],
    }
    package { 'linux-image-virtual':
       ensure  => purged,
       require => Package['linux-server'],
    }
  }
}

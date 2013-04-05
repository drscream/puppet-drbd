define drbd::resource (
  $hosts,
  $ips,
  $disk,
  $dev = '/dev/drbd0',
  $rate = '100M',
  $port = '7789',
  $metadisk = 'internal',
  $options = undef
) {

  include drbd

  file {"${drbd::config_pool}/${title}.res":
    ensure  => present,
    content => template('drbd/resource.erb'),
  }

  exec { "intialize DRBD metadata for $name":
    command => "drbdadm create-md $name",
    onlyif  => "test -e $disk",
    unless  => "drbdadm dump-md $name || (drbdadm cstate $name | egrep -q '^(Sync|Connected)')",
    before  => Service["drbd"],
    require => File["${drbd::config_pool}/${title}.res"],
  }

  exec { "enable DRBD resource $name":
    command => "drbdadm up $name",
    onlyif  => "drbdadm dstate $name | egrep -q '^Diskless/|^Unconfigured'",
    before  => Service["drbd"],
    require => Exec["intialize DRBD metadata for $name"],
  }
}

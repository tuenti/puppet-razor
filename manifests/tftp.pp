# == Class: razor::tftp
#
# Razor Provisioning: Bootfiles for "exporting" by TFTP Server
#
# This is a private class. Only use the 'razor' class.
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class razor::tftp inherits razor {
  #Root directory
  if ($::razor::tftp_root == undef) {
    $directory = $::tftp::directory
  } else {
    validate_absolute_path($::razor::tftp_root)
    $directory = $::razor::tftp_root
  }

  # undionly.kpxe
  archive { "${directory}/undionly.kpxe":
    source => 'http://boot.ipxe.org/undionly.kpxe',
  } ->

  tftp::file { 'undionly.kpxe':
    ensure => file,
    source => "${directory}/undionly.kpxe",
  }

  # bootstrap.ipxe
  archive { "${directory}/bootstrap.ipxe":
    source => "http://${::razor::server_hostname}:${::razor::real_server_http_port}/api/microkernel/bootstrap",
  } ->

  tftp::file { 'bootstrap.ipxe':
    ensure => file,
    source => "${directory}/bootstrap.ipxe",
  }
}

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
    source     => 'http://boot.ipxe.org/undionly.kpxe',
    http_proxy => $::razor::http_proxy,
  } ->

  tftp::file { $::razor::kpxe_undionly_filename:
    ensure => file,
    source => "${directory}/undionly.kpxe",
  }

  # ipxe.efi
  archive { "${directory}/ipxe.efi":
    source     => 'http://boot.ipxe.org/ipxe.efi',
    http_proxy => $::razor::http_proxy,
  } ->

  tftp::file { $::razor::ipxe_efi_filename:
    ensure => file,
    source => "${directory}/ipxe.efi",
  }

  # bootstrap.ipxe
  archive { "${directory}/bootstrap.ipxe":
    source => "http://${::razor::server_hostname}:${::razor::real_server_http_port}/api/microkernel/bootstrap",
  } ->

  tftp::file { $::razor::ipxe_bootstrap_filename:
    ensure => file,
    source => "${directory}/bootstrap.ipxe",
  }
}

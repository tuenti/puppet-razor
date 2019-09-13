# == Class: razor::microkernel
#
# Razor Provisioning: Razor microkernel download and unpack
#
# This is a private class. Only use the 'razor' class.
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class razor::microkernel inherits razor {
  # Validation
  validate_absolute_path($::razor::repo_store_path)

  include ::archive

  $verify_checksum = $::razor_microkernel_checksum ? {
    undef   => false,
    default => true,
  }
  archive { '/tmp/razor-microkernel.tar':
    ensure          => 'present',
    source          => $::razor::microkernel_url,
    extract         => true,
    extract_path    => $::razor::repo_store_path,
    checksum_verify => $verify_checksum,
    checksum        => $::razor::microkernel_checksum,
    checksum_type   => $::razor::microkernel_checksum_type,
    creates         => "${::razor::repo_store_path}/microkernel",
    cleanup         => false,
    # archive no longer supports a timeout value. Note that the microkernel is about 160 MB.
  }
}

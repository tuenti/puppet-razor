# == Definition: razor::mk_extension
#
# Razor Provisioning: Microkernel extension
#
# === Authors
#
# Victor Cabezas <vcabezas@tuenti.com>
#
class razor::mk_extension {

  archive { "${::razor::data_root_path}/mk-extension.zip":
    ensure        => present,
    source        => $::razor::mk_extension_source,
    checksum      => $::razor::mk_extension_checksum,
    checksum_type => $::razor::mk_extension_checksum_type,
  }
}

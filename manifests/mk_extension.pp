# == Definition: razor::mk_extension
#
# Razor Provisioning: Microkernel extension
#
# === Authors
#
# Victor Cabezas <vcabezas@tuenti.com>
#
class razor::mk_extension (
  String                $source,
  Variant[Undef,String] $checksum      = undef,
  Variant[Undef,String] $checksum_type = undef,
) {

  archive { "${::razor::data_root_path}/mk-extension.zip":
    ensure        => present,
    source        => $source,
    checksum      => $checksum,
    checksum_type => $checksum_type,
  }

  ::razor::razor_yaml_setting{ 'all.mk_extension':
    ensure => 'present',
    value  => {
      'all' => {
      'mk_extension' => "${::razor::data_root_path}/mk-extension.zip",
    },
  }
}

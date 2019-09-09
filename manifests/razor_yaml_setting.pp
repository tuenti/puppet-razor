# == Define: razor::razor_yaml_setting
#
# Helper define for working with yaml configurations settings.
#
# === Authors
#
# Jeremy Custenborder <jcustenborder@gmail.com>
#
define razor::razor_yaml_setting (
  Any                       $value, # Untyped - can be many things
  Enum['present', 'absent'] $ensure      = 'present',
  String                    $target      = $::razor::server_config_path,
  String                    $export_tag  = 'razor-server'
) {
  concat::fragment { $name:
    ensure  => $ensure,
    content => to_yaml({ $key => $value }),
    key     => $name,
    target  => $target,
    tag     => $export_tag,
  }
}

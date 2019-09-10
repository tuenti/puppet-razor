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
  Enum['present', 'absent'] $ensure = 'present',
  String                    $target = $::razor::server_config_path,
) {
  if $ensure == 'present' {
    concat::fragment { $name:
      content => to_yaml({ $key => $value }),
      target  => $target,
      order   => '50',
    }
  }
}

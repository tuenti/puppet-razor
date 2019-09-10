# == Class: razor::config
#
# Razor Provisioning: Server configuration file setup
#
# This is a private class. Only use the 'razor' class.
#
# === Authors
#
# Victor Cabezas <vcabezas@tuenti.com>
#
class razor::config inherits razor {
  concat { $::razor::server_config_path:
    ensure  => present,
    format  => 'yaml',
    force   => true,
  }

  concat::fragment { 'default razor server config':
    content => to_yaml($::razor::server_base_config),
    target  => $::razor::server_config_path,
    order   => '99',
  }
}


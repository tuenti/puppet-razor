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

  # Write server configuration
  if $::razor::enable_server {
    $mk_extension_setting = $::razor::enable_mk_extension ? {
      false => '',
      true  => $::razor::mk_extension_source ? {
        undef   => '',
        default => "${::razor::data_root_path}/mk-extension.zip",
      },
    }
    $tmp_server_config = deep_merge(
      $::razor::server_base_config,
      {
        'production'     => {
          'database_url' => "jdbc:postgresql://${::razor::database_hostname}/${::razor::database_name}?user=${::razor::database_username}&password=${::razor::database_password}",
        },
        'all' => {
          'repo_store_root' => $::razor::repo_store_path,
          'match_nodes_on'  => $::razor::match_nodes_on,
          'microkernel'     => {
            'extension-zip' => $mk_extension_setting,
          },
        },
      }
    )

    $server_configuration = deep_merge(
      $tmp_server_config,
      $::razor::server_config_override,
    )

    file { $::razor::server_config_path:
      ensure  => present,
      content => to_yaml($server_configuration),
    }

    file { "/etc/sysconfig/${razor::server_service_name}":
      ensure  => present,
      content => epp("${module_name}/sysconfig.epp"),
    }
  }

  # TODO: Move api configuration here
}


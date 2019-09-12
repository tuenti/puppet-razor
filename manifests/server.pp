# == Class: razor::server
#
# Razor Provisioning: Server Setup
#
# This is a private class. Only use the 'razor' class.
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class razor::server inherits razor {
  # Validation
  assert_type(String, $::razor::database_password) |$expected, $actual| {
    fail('database_password is a required parameter with enable_server = true.')
  }
  validate_absolute_path($::razor::server_config_path)
  validate_absolute_path($::razor::repo_store_path)

  # Compatibility
  case $::osfamily {
    'debian': {
      case $::operatingsystem {
        'Ubuntu': {
          case $::lsbdistcodename {
            'lucid','maverick','natty','oneiric': {
              # Lucid - OK
            }
            'precise','quantal','raring','saucy': {
              # Precise - OK
            }
            'trusty','utopic','vivid', 'wily': {
              # Trusty - OK
            }
            'xenial', 'yakkety', 'zesty', 'artful': {
              # Xenial - OK
            }
            'bionic': {
              fail("Ubuntu Xenial (>= 18.04) is not supported yet! ${::lsbdistcodename}")
            }
            default: {
              fail("Ubuntu < 10.04 and >= 18.04 is not supported: ${::lsbdistcodename}")
            }
          }
        }
        'Debian': {
          case $::lsbdistcodename {
            'squeeze','wheezy','jessie','stretch': {
              # Squeeze (6) - OK
              # Wheezy (7) - OK
              # Jessie (8) - OK
              # Stretch (9) - OK
            }
            default: {
              fail("Debian < 6 and > 10 is not supported: ${::lsbdistcodename}")
            }
          }
        }
        default: {
          fail("Operating System (debian) is not supported: ${::operatingsystem}")
        }
      }
    }
    'redhat': {
      case $::operatingsystem {
        'CentOS': {
          case $::operatingsystemmajrelease {
            '5': {
              # EL 5(x) - OK
              # EL 5.0 - 5.9 - OK
            }
            '6': {
              # EL 6(x) - OK
              # EL 6.0 - 6.5 - OK
            }
            '7': {
              # EL 7.1 - OK
            }
            default: {
              fail("CentOS/RHEL < 5 and > 7 is not supported: ${::operatingsystemmajrelease}")
            }
          }
        }
        'Fedora': {
          case $::operatingsystemmajrelease {
            '19': {
              fail('Fedora 19 is not supported')
            }
            '20': {
              # Fedora 20 - OK
            }
            default: {
              fail("Fedora < 20 and > 20 is not supported: ${::operatingsystemmajrelease}")
            }
          }
        }
        default: {
          fail("Operating System (Redhat) is not supported: ${::operatingsystem}")
        }
      }
    }
    default: {
      fail("Operating System Family is not supported: ${::osfamily}")
    }
  }

  # Installation
  if ($::razor::enable_aio_support == false) {
    # Torquebox was auto-dependency < 1.0.0, but no longer by 1.3.0
    # From 1.4.0 (AIO packaging), it is included in the server package.
    package { $::razor::torquebox_package_name:
      ensure => $::razor::torquebox_package_version,
    } -> Package[$::razor::server_package_name]
  }

  package { $::razor::server_package_name:
    ensure => $::razor::server_package_version,
  } ~>  Exec['razor-migrate-database']

  # Service
  service { $::razor::server_service_name:
    ensure => 'running',
    enable => true,
  }

  # Setup the Database
  exec { 'razor-migrate-database':
    cwd         => $::razor::data_root_path,
    path        => [
      '/bin', '/sbin',
      '/usr/bin', '/usr/sbin',
      '/usr/local/bin', '/usr/local/sbin',
      $::razor::binary_path, $::razor::jruby_binary_path,
    ],
    command     => 'razor-admin -e production migrate-database',
    refreshonly => true,
    notify      => [
      Exec['razor-redeploy'],
      Service[$::razor::server_service_name]
    ],
  }

  # Redeploy application (required when upgrading)
  $source    = "source ${::razor::real_config_dir}/razor-torquebox.sh"
  $torquebox = "torquebox deploy ${::razor::data_root_path} --env=production"
  exec { 'razor-redeploy':
    cwd         => $::razor::data_root_path,
    path        => [
      '/bin', '/sbin',
      '/usr/bin', '/usr/sbin',
      '/usr/local/bin', '/usr/local/sbin',
      $::razor::torquebox_binary_path,
    ],
    command     => "bash -c '${source}; ${torquebox}'",
    refreshonly => true,
    notify      => Service[$::razor::server_service_name],
  }

  create_resources('razor::task',      $::razor::tasks)
  create_resources('razor::broker',    $::razor::brokers)
  create_resources('razor::hook_type', $::razor::hooks)
  create_resources('razor_tag',        $::razor::tags)
  create_resources('razor_policy',     $::razor::policies)
  create_resources('razor_repo',       $::razor::repos)
  create_resources('razor_broker',     $::razor::api_brokers)
  create_resources('razor_hook',       $::razor::api_hooks)

  # Ordering
  Package[$::razor::server_package_name] -> File[$::razor::server_config_path] -> Service[$::razor::server_service_name]
  File[$::razor::server_config_path] ~> Exec['razor-migrate-database']
  File[$::razor::server_config_path] ~> Service[$::razor::server_service_name]
  Razor_tag<| |>    -> Razor_policy<| |>
  Razor_repo<| |>   -> Razor_policy<| |>
  Razor_broker<| |> -> Razor_policy<| |>
  Razor::Task<| |>  -> Razor_policy<| |>
  Razor::Hook_type<| |> -> Razor_hook<| |>
  Razor::Broker<| |> -> Razor_broker<| |>
  Package[$::razor::server_package_name] -> Razor::Task<| |>
  Package[$::razor::server_package_name] -> Razor::Broker<| |>
  Package[$::razor::server_package_name] -> Razor::Hook_type<| |>
  Service[$::razor::server_service_name] -> Razor_tag<| |>
  Service[$::razor::server_service_name] -> Razor_policy<| |>
  Service[$::razor::server_service_name] -> Razor_repo<| |>
  Service[$::razor::server_service_name] -> Razor_broker<| |>
  Service[$::razor::server_service_name] -> Razor_hook<| |>
}

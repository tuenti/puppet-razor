# == Class: razor::api
#
# Class for configuring the API access that is used by Custom Types.
#
# === Parameters
# * hostname (string): The hostname on which the Razor Server is located. Default: localhost
# * port (integer): HTTP server port for the API. Default: (8150 unless Razor < 1.1.0 is detected locally)
#
# === Examples
#  class{ 'razor::api': }
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
class razor::api (
  String $hostname              = 'localhost',
  Variant[Undef, Integer] $port = undef,
  String $rest_client_version   = present,
  String $gem_provider          = 'puppet_gem',
  String $gem_package_mirror    = $::razor::params::gem_package_mirror,
  # TODO - Shiro Authentication
) inherits razor::params {
  # Parameters
  $config_dir = '/etc/razor'

  if ($port == undef) {
    if ($::razorserver_version != undef and versioncmp($::razorserver_version, '1.1.0') < 0) {
      $api_port = 8080
    } else {
      $api_port = 8150
    }
  } else {
    $api_port = $port
  }

  # Ensure configuration directory exists (fixed path in custom types)
  ensure_resource('file', [$config_dir], {'ensure' => 'directory'})

  # Configuration File
  file { "${config_dir}/api.yaml":
    ensure  => 'file',
    content => template('razor/api.yaml.erb')
  }

  # Dependencies
  if ($::operatingsystem == 'Ubuntu') {
    ensure_packages(['build-essential', 'g++'], {'ensure' => 'present'})
  }

  # Dependency Gems Installation
  ensure_packages(['rest-client', 'retries'], {
    'ensure'          => $rest_client_version,
    'install_options' => ['--source', $gem_package_mirror],
    'provider'        => $gem_provider,
  })
}

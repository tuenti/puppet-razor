# Class: razor::params
#
# Contains system-specific parameters
#
# Parameters:
#   * compile_microkernel (boolean): Whether to compile the microkernel (only supported on RedHat)
#   * client_package_name (string): Package name for Razor Client
#   * gem_package_mirror (string): Rubygems mirror where to download Ruby gems
#   * server_package_name (string): Package name for Razor Server
#   * torquebox_package_name (string): Package name for Torquebox
#   * server_config_file (string): Filename for configuration of Razor Server
#   * server_service_name (string): Name of the service that manages Razor Server
#   * microkernel_url (string): URL of where to download Microkernel (tarball). Set undef to skip.
#   * microkernel_checksum (string|undef): Microkernel file checksum
#   * microkernel_checksum_type (string): Microkernel file checksum type
#   * match_nodes_on (array): unique identifiers for the node (?)
#
class razor::params {
  if ($::operatingsystem =~ 'CentOS') {
    if (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
      $compile_microkernel = true
    } else {
      $compile_microkernel = false
    }
  } else {
    $compile_microkernel = false
  }

  $client_package_name    = 'razor-client'
  $gem_package_mirror     = 'https://rubygems.org'
  $server_package_name    = 'razor-server'
  $torquebox_package_name = 'razor-torquebox'

  $ipxe_efi_filename       = 'ipxe.efi'
  $kpxe_undionly_filename  = 'undionly.kpxe'
  $ipxe_bootstrap_filename = 'bootstrap.ipxe'

  $server_config_file  = 'config.yaml'
  $server_service_name = 'razor-server'
  $server_config_default = {
    'production' => {
      'database_url' => 'jdbc:postgresql:razor_prd?user=razor&password=mypass',
    },
    'development' => {
      'database_url' => 'jdbc:postgresql:razor_dev',
    },
    'test' => {
      'database_url' => 'jdbc:postgresql:razor?user=razor&password=mypass',
    },
    'all' => {
      'auth' => {
        'enabled'         => false,
        'config'          => 'shiro.ini',
        'allow_localhost' => false,
      },
      'microkernel' => {
        'debug_level' => 'debug',
        'kernel_args' => '',
        # 'extension-zip' => '/etc/puppetlabs/razor-server/mk-extension.zip',
      },
      'secure_api'          => false,
      'protect_new_nodes'   => true,
      'store_hook_input'    => true,
      'store_hook_output'   => true,
      'match_nodes_on'      => ['mac'],
      'checkin_interval'    => 15,
      'task_path'           => 'tasks',
      'repo_store_root'     => '/opt/puppetlabs/server/data/razor-server/repo',
      'broker_path'         => 'brokers',
      'hook_path'           => 'hooks',
      'hook_execution_path' => '',
      'facts'               => {
        'blacklist'         => [
          'domain',
          'filesystems',
          'fqdn',
          'hostname',
          'id',
          '/kernel.*/',
          'memoryfree',
          'memorysize',
          'memorytotal',
          '/operatingsystem.*/',
          'osfamily',
          'path',
          'ps',
          'rubysitedir',
          'rubyversion',
          'selinux',
          'sshdsakey',
          '/sshfp_[dr]sa/',
          'sshrsakey',
          '/swap.*/',
          'timezone',
          '/uptime.*/',
        ],
      },
      'api_config_blacklist' => ['database_url', 'facts.blacklist'],
    },
  }

  $microkernel_url      = 'http://links.puppetlabs.com/razor-microkernel-latest.tar'
  $microkernel_checksum = undef
  $microkernel_type     = 'md5'

  $match_nodes_on = ['mac']
}

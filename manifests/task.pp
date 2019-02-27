# == Definition: razor::task
#
# Razor Provisioning: Task
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
define razor::task (
  $module    = 'razor',
  $directory = 'tasks',
  $root      = "${::razor::data_root_path}/tasks",
  $source    = undef,
) {
  # Validation
  validate_absolute_path($root)

  $source_ = $source ? {
    undef   => "puppet:///modules/${module}/${directory}/${name}.task",
    default => $source,
  }

  # Create directory
  Package[$::razor::server_package_name]
  ->
  file { "${root}/${name}.task":
    ensure  => 'directory',
    source  => $source_,
    recurse => true,
  }
}

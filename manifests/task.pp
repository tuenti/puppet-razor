# == Definition: razor::task
#
# Razor Provisioning: Task
#
# === Authors
#
# Nicolas Truyens <nicolas@truyens.com>
#
define razor::task (
  String $module                 = 'razor',
  String $directory              = 'tasks',
  String $root                   = "${::razor::data_root_path}/tasks",
  Variant[Undef, String] $source = undef,
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
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => $source_,
    recurse => true,
  }
}

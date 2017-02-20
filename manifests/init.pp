# == Class: consular
#
# Installs Consular from a PPA and adds an Upstart definition.
#
# === Parameters
#
# [*ensure*]
#   Global ensure value for Consular. Valid values are 'present' and 'absent'.
#   When 'absent' is passed, the package, config and service will be removed.
#
# [*package_ensure*]
#   The ensure value for the Consular package. If *ensure* is 'absent' then this
#   parameter is ignored and the package is purged.
#
# [*repo_manage*]
#   Whether or not to manage the repository for Consular.
#
# [*repo_source*]
#   The repo source to use. Current valid values: 'ppa-jerith'.
#
# [*host*]
#   The address for Consular to listen on for connections from Marathon.
#
# [*port*]
#   The port for Consular to listen on for connections from Marathon.
#
# [*consul*]
#   The full address to use to connect to Consul.
#
# [*marathon*]
#   The full address to use to connect to Marathon.
#
# [*registration_id*]
#   The registration ID to use when registering for callbacks with Marathon.
#
# [*sync_interval*]
#   The number of seconds between syncs. If 0, syncing will be disabled.
#
# [*purge*]
#   Whether or not to purge old Consular-registered services during syncs.
#
# [*extra_opts*]
#   A hash of additional options to pass to Consular. NOTE: these options can
#   override any of the above options.
#   e.g. { 'timeout' => 10 }
class consular (
  $ensure          = 'present',
  $package_ensure  = 'installed',
  $repo_manage     = true,
  $repo_source     = 'ppa-jerith',
  $host            = $::ipaddress_lo,
  $port            = 7000,
  $consul          = "http://${::ipaddress_lo}:8500",
  $marathon        = "http://${::ipaddress_lo}:8080",
  $registration_id = $::hostname,
  $sync_interval   = 0,
  $purge           = false,
  $extra_opts      = {},
) {
  validate_re($ensure, '^(present|absent)$')
  validate_bool($repo_manage)
  validate_ip_address($host)
  validate_integer($port)
  validate_integer($sync_interval)
  validate_bool($purge)
  validate_hash($extra_opts)

  $purge_flag = $purge ? {
    true  => 'purge',
    false => 'no-purge',
  }
  $base_opts = {
    'host'            => $host,
    'port'            => $port,
    'consul'          => $consul,
    'marathon'        => $marathon,
    'registration-id' => $registration_id,
    'sync-interval'   => $sync_interval,
    "${purge_flag}"   => '',
  }
  $final_opts = merge($base_opts, $extra_opts)

  $_package_ensure = $ensure ? {
    'present' => $package_ensure,
    'absent'  => 'purged',
  }

  $_service_ensure = $ensure ? {
    'present' => 'running',
    'absent'  => 'stopped',
  }

  class { 'consular::repo':
    manage => $repo_manage,
    ensure => $ensure,
    source => $repo_source,
  }
  ->
  package { 'python-consular':
    ensure  => $_package_ensure,
  }
  ->
  file { '/etc/init/consular.conf':
    ensure  => $ensure,
    content => template('consular/init.conf.erb'),
  }
  ~>
  service { 'consular':
    ensure => $_service_ensure,
  }

  Package['python-consular'] ~> Service['consular']
}

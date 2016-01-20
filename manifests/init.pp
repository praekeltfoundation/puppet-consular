# == Class: consular
#
# Installs Consular from a PPA and adds an Upstart definition.
#
# === Parameters
#
# [*ensure*]
#   The ensure value for the package.
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
# [*opts*]
#   A hash of additional options to pass to Consular. NOTE: these options can
#   override any of the above options.
#   e.g. { 'timeout' => 10 }
class consular (
  $ensure          = 'installed',
  $host            = $::ipaddress_lo,
  $port            = 7000,
  $consul          = "http://${::ipaddress_lo}:8500",
  $marathon        = "http://${::ipaddress_lo}:8080",
  $registration_id = $::hostname,
  $sync_interval   = 0,
  $purge           = false,
  $opts            = {},
) {
  validate_ip_address($host)
  validate_integer($port)
  validate_integer($sync_interval)
  validate_bool($purge)
  validate_hash($opts)

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
  $final_opts = merge($base_opts, $opts)

  include apt
  # NOTE: This is a temporary PPA that is managed manually by a single
  # individual in his personal capacity. It needs to be replaced with a better
  # one that gets automated package updates and such.
  apt::ppa { 'ppa:jerith/consular': ensure => 'present' }
  ->
  file { '/etc/init/consular.conf':
    content => template('consular/init.conf.erb'),
  }
  ~>
  package { 'python-consular':
    ensure  => $ensure,
    require => Class['apt::update'],
  }
  ~>
  service { 'consular':
    ensure => running,
  }
}

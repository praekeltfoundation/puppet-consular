# == Class: consular
#
# Installs Consular from a PPA and adds an Upstart definition.
#
# === Parameters
#
# [*ensure*]
#   The ensure value for the package.
#
# [*consular_args*]
#   A list of arguments to pass to Consular at runtime.
class consular (
  $ensure        = 'installed',
  $consular_args = [],
) {
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

# == Class: consular::repo
#
class consular::repo (
  $manage = true,
  $ensure = 'present',
  $source = 'ppa-jerith',
) {
  if $manage {
    case $source {
      'ppa-jerith': {
        include apt

        # NOTE: This is a temporary PPA that is managed manually by a single
        # individual in his personal capacity. It needs to be replaced with a
        # better one that gets automated package updates and such.
        apt::ppa { 'ppa:jerith/consular':
          ensure => $ensure
        }

        # Ensure apt-get update runs as part of this class
        contain 'apt::update'
      }
      default: {
        fail("APT repository '${source}' is not supported.")
      }
    }
  }
}

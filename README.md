# puppet-consular
Puppet module for managing [Consular](http://consular.readthedocs.org).

This is a very simple module and does not include a lot of features. It is only compatible with certain versions of Ubuntu (those that use Upstart as their init system) and has only been tested on Ubuntu 14.04.

**NOTE:** We currently provide Consular packages from a PPA. This is a temporary PPA that is managed manually by a single individual in his personal capacity. It needs to be replaced with a better one that gets automated package updates and such.

### Usage
```puppet
class { 'consular':
  ensure        => 'latest',
  host          => $::ipaddress_eth0,
  port          => 7070,
  consul        => 'http://127.0.0.1:8500',
  marathon      => 'http://127.0.0.1:8080',
  sync_interval => 300,
  purge         => true,
}
```
For a full list of options see the [manifest source](manifests/init.pp).

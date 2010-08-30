#
# modules/nagios/manifests/definitions/host-local.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::local::hostgroup ($ensure=present) {

  include nagios::params

  $fname = regsubst($name, "\W", "_", "G")

  nagios_hostgroup { $name:
    ensure  => $ensure,
    target  => "${nagios::params::resourcedir}/hostgroup-${fname}.cfg",
    notify  => Exec["nagios-reload"],
  }

  file { "${nagios::params::resourcedir}/hostgroup-${fname}.cfg":
    ensure => $ensure,
    before => Nagios_hostgroup[$name],
  }

}

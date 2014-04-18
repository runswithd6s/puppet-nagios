# == Class: nagios::params
#
# This class defines a few of attributes which are used in many classes and
# definitions of this module.
#
class nagios::params {

  $basename = $::osfamily ? {
    'Debian' => 'nagios3',
    'RedHat' => 'nagios',
  }

  $resourcedir = '/etc/nagios.d'
  $rootdir     = "/etc/${basename}"
  $conffile    = "${rootdir}/nagios.cfg"

  $nrpe_server_tag = $nagios_nrpe_server_tag
  $nsca_server = $nagios_nsca_server
  $nsca_server_tag = $nagios_nsca_server_tag
}

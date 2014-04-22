# == Class: nagios::server::redhat
#
# Define common resources specific to redhat based systems. 
#
# if $::osfamily =~ 'RedHat|CentOS' {
#     class {'::nagios::server::redhat':
#         use_syslog => 1
#      } 
#
class nagios::server::redhat {

  include nagios::params

  # Used for notification templates
  $nagios_mail_path = '/bin/mail'

  $user1 = $::architecture ? {
    'x86_64' => '/usr/lib64/nagios/plugins',
    default  => '/usr/lib/nagios/plugins',
  }
  #nagios::resource { 'USER1': value => $user1, }

  package { 'nagios':
    ensure => present,
  }

  class {'nagios::server' :
    cfg_dir => ['/etc/nagios.d', '/etc/nagios/objects'],
  }

}

# == Class: nagios::debian
#
# Define common resources specific to debian based systems. It shouldn't be
# necessary to include this class directly. Instead, you should use:
#
#   include nagios
#
class nagios::debian inherits nagios::base {

  $user1 = '/usr/lib/nagios/plugins'
  $p1file = '/usr/lib/nagios3/p1.pl'
  $nagios_mail_path = '/usr/bin/mail'
 
  package {[
    'nagios3-common',
    'nagios-plugins',
    'nagios-plugins-standard',
    'nagios-plugins-basic',
    ]:
    ensure => installed,
  }
  package {'nagios3-core':
    ensure => installed,
    alias  => 'nagios',
  }

  Service['nagios'] {
    name => 'nagios3',
  }

  File['/var/lib/nagios3'] {
    mode => '0751',
  }


  # debian specific resources below

  file {'/etc/default/nagios3':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nagios/etc/default/nagios3.erb'),
    require => Package['nagios'],
  }

}

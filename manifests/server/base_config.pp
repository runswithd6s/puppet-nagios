# == Class: nagios::server::base_config
#
# Define common resources between debian and redhat based systems. It shouldn't
# be necessary to include this class directly. Instead, you should use:
#
#   include nagios
#
class nagios::server::base_config {

  include nagios::params
  # nagios::resource { 'USER1': value => $nagios::params::user1 }

  # concat {[
  #     $nagios::params::conffile,
  #     "${nagios::params::rootdir}/resource.cfg",
  #   ]:
  #   notify => Service['nagios'],
  #   require => Package['nagios'],
  # }

  # purge undefined nagios resources
  file { $nagios::params::resourcedir:
    ensure  => directory,
    source  => 'puppet:///modules/nagios/empty',
    owner   => root,
    group   => root,
    mode    => '0644',
    purge   => true,
    force   => true,
    recurse => true,
    notify  => Service['nagios'],
  }

  file {"${nagios::params::resourcedir}/generic-host.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/nagios/generic-host.cfg',
    notify  => Service['nagios'],
  }

  file {"${nagios::params::resourcedir}/generic-command.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nagios/generic-command.cfg.erb'),
    notify  => Service['nagios'],
  }

  file {"${nagios::params::resourcedir}/generic-service.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/nagios/generic-service.cfg',
    notify  => Service['nagios'],
  }

  file {"${nagios::params::resourcedir}/generic-timeperiod.cfg":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/nagios/generic-timeperiod.cfg',
    notify  => Service['nagios'],
  }

  file {"${nagios::params::resourcedir}/base-contacts.cfg":
    ensure => present,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_contact { 'root':
    contact_name                  => 'root',
    alias                         => 'Root',
    service_notification_period   => '24x7',
    host_notification_period      => '24x7',
    service_notification_options  => 'w,u,c,r',
    host_notification_options     => 'd,r',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
    email                         => 'root',
    target                        => "${nagios::params::resourcedir}/base-contacts.cfg",
    notify                        => Service['nagios'],
    require                       => File["${nagios::params::resourcedir}/base-contacts.cfg"],
  }

  file {"${nagios::params::resourcedir}/base-contactgroups.cfg":
    ensure => present,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_contactgroup { 'admins':
    contactgroup_name => 'admins',
    alias             => 'Nagios Administrators',
    members           => 'root',
    target            => "${nagios::params::resourcedir}/base-contactgroups.cfg",
    notify            => Service['nagios'],
    require           => [
      Nagios_contact['root'],
      File["${nagios::params::resourcedir}/base-contactgroups.cfg"]
    ],
  }

  file {"${nagios::params::resourcedir}/base-servicegroup.cfg":
    ensure => present,
    owner  => 'root',
    mode   => '0644',
  }

  nagios_servicegroup { 'default':
    alias   => 'Default Service Group',
    target  => "${nagios::params::resourcedir}/base-servicegroup.cfg",
    notify  => Service['nagios'],
    require => File["${nagios::params::resourcedir}/base-servicegroup.cfg"],
  }

}

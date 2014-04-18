# == Class: nagios::server::redhat
#
# Define common resources specific to redhat based systems. 
#
# if $::osfamily =~ 'RedHat|CentOS' {
#     class {'::nagios::server::redhat':
#         use_syslog => 1
#      } 
#
class nagios::server::redhat inherits nagios::server {

  include nagios::params

  # Used for notification templates
  $nagios_mail_path = '/bin/mail'

  $user1 = $::architecture ? {
      'x86_64' => '/usr/lib64/nagios/plugins',
      default  => '/usr/lib/nagios/plugins',
  }
  nagios::resource { 'USER1': value => $nagios::params::user1 }

  package { 'nagios':
    ensure => present,
  }

  # Needed to make augeas work for nagios.cfg
  file { '/etc/nagios3':
    ensure => link,
    target => '/etc/nagios'
  }


  # Service['nagios'] {
  #   hasstatus   => false,
  #   pattern     => '/usr/sbin/nagios -d /etc/nagios/nagios.cfg',
  # }

  case $::lsbmajdistrelease {

    '5','6': {
      File[
        '/var/nagios',
        '/var/run/nagios',
        '/var/log/nagios',
        '/var/lib/nagios',
        '/var/lib/nagios/spool',
        $check_result_path,
        '/var/cache/nagios'
        ] {
        seltype => 'nagios_log_t',
      }

      File['nagios read-write dir'] {
        seltype => 'nagios_log_t',
      }

      exec { "chcon $command_file":
        require => [Exec['create fifo'], File['nagios read-write dir']],
        command => "chcon -t nagios_spool_t ${command_file}",
        unless  => "ls -Z ${command_file} | grep -q nagios_spool_t",
        onlyif  => $::selinux,
      }

      file {[
        $state_retention_file,
        $temp_file,
        $status_file,
        $precached_object_file,
        $object_cache_file,
      ]:
        ensure   => present,
        seltype  => 'nagios_log_t',
        owner    => $nagios_user,
        group    => $nagios_group,
        loglevel => 'debug',
        require  => File['/var/run/nagios'],
      }
      File[$state_retention_file] { mode => '0600', }
      File[$status_file]  { mode => '0664', }
    }

  }

  # # workaround broken init-script
  # Exec['nagios-restart'] {
  #   command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -f '^/usr/sbin/nagios' && /etc/init.d/nagios start",
  # }

  # Exec['nagios-reload'] {
  #   command => "nagios -v ${nagios::params::conffile} && pkill -P 1 -HUP -f '^/usr/sbin/nagios'",
  # }

}

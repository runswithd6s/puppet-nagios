# Build a server with options from the nagios.cfg config file as
# parameters
class nagios::server (
  $service_name='nagios',
  $nagios_config_file='/etc/nagios/nagios.cfg',
  # Nagios config file options
  $accept_passive_host_checks=1,
  $accept_passive_service_checks=1,
  $additional_freshness_latency=15,
  $admin_email=undef,
  $admin_pager=undef,
  $auto_reschedule_checks=0,
  $auto_rescheduling_interval=30,
  $auto_rescheduling_window=180,
  $broker_module=undef,
  $cached_host_check_horizon=15,
  $cached_service_check_horizon=15,
  # can have mulitple files
  $cfg_file=undef,
  $cfg_dir=['/etc/nagios.d',],
  $check_external_commands=1,
  $check_for_orphaned_hosts=1,
  $check_for_orphaned_services=1,
  $check_host_freshness=1,
  $check_result_path='/var/nagios/spool/checkresults',
  $check_result_reaper_frequency=10,
  $check_service_freshness=1,
  $child_processes_fork_twice=1,
  $command_check_interval=-1,
  $command_file='/var/nagios/rw/nagios.cmd',
  $daemon_dumps_core=0,
  $date_format='iso8601',
  $debug_file='/var/nagios/nagios.debug',
  $debug_level=0,
  $debug_verbosity=0,
  $enable_embedded_perl=1,
  $enable_environment_macros=1,
  $enable_event_handlers=1,
  $enable_flap_detection=1,
  $enable_notifications=1,
  $enable_predictive_host_dependency_checks=1,
  $enable_predictive_service_dependency_checks=1,
  $event_broker_options=-1,
  $event_handler_timeout=30,
  $execute_host_checks=1,
  $execute_service_checks=1,
  $external_command_buffer_slots=4096,
  $free_child_process_memory=undef,
  $global_host_event_handler=undef,
  $global_service_event_handler=undef,
  $high_host_flap_threshold=20.0,
  $high_service_flap_threshold=20.0,
  $host_check_timeout=60,
  $host_freshness_check_interval=60,
  $host_inter_check_delay_method='s',
  $host_perfdata_command=undef,
  $host_perfdata_file=undef,
  $host_perfdata_file_mode='a',
  $host_perfdata_file_processing_command=undef,
  $host_perfdata_file_processing_interval=undef,
  $host_perfdata_file_template=undef,
  $illegal_macro_output_chars='`~$&|\'"<>',
  $illegal_object_name_chars='`~!$%^&*|\'"<>?,()=',
  $interval_length=60,
  $lock_file='/var/nagios/nagios.pid',
  $log_archive_path='/var/nagios/archives',
  $log_event_handlers=0,
  $log_external_commands=0,
  $log_file='/var/nagios/nagios.log',
  $log_host_retries=0,
  $log_initial_states=0,
  $log_notifications=0,
  $log_passive_checks=0,
  $log_rotation_method=d,
  $log_service_retries=0,
  $low_host_flap_threshold=5.0,
  $low_service_flap_threshold=5.0,
  $max_check_result_file_age=3600,
  $max_check_result_reaper_time=30,
  $max_concurrent_checks=0,
  $max_debug_file_size=1000000 ,
  $max_host_check_spread=30,
  $max_service_check_spread=30,
  $nagios_group=nagios,
  $nagios_user=nagios,
  $notification_timeout=30,
  $object_cache_file='/var/nagios/objects.cache',
  $obsess_over_hosts=1,
  $obsess_over_services=1,
  $ocsp_command=undef,
  $ocsp_timeout=10,
  $p1_file='/usr/sbin/p1.pl',
  $passive_host_checks_are_soft=0,
  $perfdata_timeout=5,
  $precached_object_file='/var/nagios/objects.precache',
  $process_performance_data=0,
  $resource_file='/etc/nagios/resource.cfg',
  $retain_state_information=1,
  $retained_contact_host_attribute_mask=0,
  $retained_contact_service_attribute_mask=0,
  $retained_host_attribute_mask=0,
  $retained_process_host_attribute_mask=0,
  $retained_process_service_attribute_mask=0,
  $retained_service_attribute_mask=0,
  $retention_update_interval=60,
  $service_check_timeout=60,
  $service_freshness_check_interval=60,
  $service_inter_check_delay_method=s,
  $service_interleave_factor=s,
  $service_perfdata_command=undef,
  $service_perfdata_file=undef,
  $service_perfdata_file_mode=a,
  $service_perfdata_file_processing_command=undef,
  $service_perfdata_file_processing_interval=undef,
  $service_perfdata_file_template=undef,
  $sleep_time=0.25,
  $soft_state_dependencies=0,
  $state_retention_file='/var/nagios/retention.dat',
  $status_file='/var/nagios/status.dat',
  $status_update_interval=10,
  $temp_file='/var/nagios/nagios.tmp',
  $temp_path='/tmp',
  $translate_passive_host_checks=0,
  $use_aggressive_host_checking=0,
  $use_embedded_perl_implicitly=1,
  $use_large_installation_tweaks=0,
  $use_regexp_matching=0,
  $use_retained_program_state=0,
  $use_retained_scheduling_info=1,
  $use_syslog=1,
  $use_timezone='US/Central',
  $use_true_regexp_matching=0,
)
{
  # Pull in the basename stuff?
  include ::nagios::params

  user { $nagios_user:
    ensure  => present,
    shell   => '/bin/sh',
    require => Package['nagios'],
  }

  group { $nagios_group:
    ensure  => present,
    require => Package['nagios'],
  }

  service { 'nagios':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    alias      => 'nagios-restart',
    require    => [ Package['nagios'], Exec['nagios-configtest'], ],
    subscribe => File[$nagios_config_file],
  }

  # Run LSB 'service' to start/stop/reload
  # Called from service, command, contact, etc...
  exec { 'nagios-configtest':
    command     => "service ${service_name} configtest",
    refreshonly => true,
  }

  exec { 'nagios-reload':
    command     => "service ${service_name} reload",
    refreshonly => true,
    require => Exec['nagios-configtest']
  }

  # Main configuration file
  file {$nagios_config_file:
    owner => $nagios_user,
    group => $nagios_group,
    mode => '0644',
    content => template('nagios/nagios.cfg.erb'),
    notify => Exec['nagios-configtest'],
  }

  # Set up config directories -- requires defined types
  if $cfg_dir != undef {
    nagios::server::cfg_dir { $cfg_dir:
       nagios_user => $nagios_user,
       nagios_group => $nagios_group,
       nagios_config_file => $nagios_config_file,
     }
  }

  # Set up config directories -- requires defined types
  if $cfg_file != undef {
    nagios::server::cfg_file{ $cfg_file:
      nagios_user => $nagios_user,
      nagios_group => $nagios_group,
      nagios_config_file => $nagios_config_file,
    }
  }

  # Create files and directories
  file { 'nagios read-write dir':
    ensure  => directory,
    path    => regsubst($command_file, '/([^/]*)$', ''),
    owner   => $nagios_user,
    group   => $nagios_group,
    mode    => '2710',
    require => Package['nagios'],
  }
  exec {'create fifo':
    command => "mknod -m 0664 ${command_file} p && chown ${nagios_user}:${nagios_group} ${command_file}",
    unless  => "test -p ${command_file}",
    require => File['nagios read-write dir'],
  }

}

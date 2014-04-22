# Class to add a cfg_file to the nagios configuration file
define nagios::server::cfg_file (
  $config_file = $title,
  $nagios_user,
  $nagios_group,
  $nagios_config_file = '/etc/nagios3/nagios.cfg',
)
{
  # Build the config dir
  file {$config_file:
    ensure => present,
    owner => $nagios_user,
    group => $nagios_group,
    mode => '0750',
  }

  # Append cfg_file=$config_file path to nagios.cfg file
  augeas { "cfg_file=$config_file in $nagios_config_file":
    incl => $nagios_config_file,
    lens => 'NagiosCfg.lns',
    context => "/files$nagios_config_file",
    changes => "set cfg_file[last()+1] ${config_file}",
    require => File[$nagios_config_file, $config_file],
    notify => Service['nagios'],
  }
}

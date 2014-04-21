# Class to add a cfg_dir to the nagios configuration file
define nagios::server::cfg_dir (
  $config_dir = $title,
  $nagios_user,
  $nagios_group,
  $nagios_config_file = '/etc/nagios3/nagios.cfg',
)
{
  # Build the config dir
  file {$config_dir:
    ensure => directory,
    owner => $nagios_user,
    group => $nagios_group,
    mode => '0750',
  }

  # Append cfg_dir=$config_dir path to nagios.cfg file
  augeas { "cfg_dir=$config_dir in $nagios_config_file":
    incl => "$nagios_config_file",
    lens => 'nagioscfg.aug',
    changes => [
                "ins cfg_dir after cfg_dir",
                "set cfg_dir/[last()] ${config_dir}"
                ],
    onlyif => "match cfg_dir != [$config_dir]",
    require => File[$nagios_config_file, $config_dir],
    notify => Service['nagios']
  }
}

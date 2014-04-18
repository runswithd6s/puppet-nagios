# Class to add a cfg_file to the nagios configuration file
class nagios::server::cfg_file (
  $config_file,
  $nagios_user,
  $nagios_group,
  $nagios_config_file = '/etc/nagios3/nagios.cfg',
)
{
  # Build the config dir
  file {$config_file:
    ensure => directory,
    owner => $nagios_user,
    group => $nagios_group,
    mode => '0750',
  }

  # Append cfg_file=$config_file path to nagios.cfg file
  augeas { "cfg_file=$config_file in $nagios_config_file":
    incl => "$nagios_config_file",
    changes => [
                "ins cfg_file after cfg_file",
                "set cfg_file/[last()] ${config_file}"
                ],
    onlyif => "match cfg_file != [$config_file]",
    requires => File[$nagios_config_file],
  }
}

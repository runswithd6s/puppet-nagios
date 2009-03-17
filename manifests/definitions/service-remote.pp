#
# modules/nagios/manifests/definitions/service-remote.pp 
# manage distributed monitoring with nagios
# Copyright (C) 2008 Mathieu Bornoz <mathieu.bornoz@camptocamp.com>
# See LICENSE for the full license granted to you.
#

define nagios::service::remote ($ensure=present, $service_description="", $host="") {
  
  $desc = $service_description ? {
    "" => $name,
    default => $service_description,
  }

  $host_name = $host ? {
    "" => $fqdn,
    default => $host,
  }

  @@nagios_service {"@@$name":                
    ensure                => $ensure,
    use                   => "generic-service-passive",
    host_name             => $host_name,
    tag                   => "nagios",
    service_description   => $desc,
    target                => "$nagios_cfg_dir/services.cfg",
    require               => File["$nagios_cfg_dir/services.cfg"],
    notify                => Exec["nagios-reload"],
  }
}

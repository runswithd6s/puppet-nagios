#
# Fix a bug with Nagios_* Resource file creation
#
class nagios::monkeypatch(
  $site_ruby='/opt/puppet/lib/ruby/site_ruby/1.9.1/',
  $resource_dir='/etc/nagios.d/',
) {

  # Monkey-patch to fix puppet bug: https://projects.puppetlabs.com/issues/17871
  exec { 'projects-puppetlabs-com-issues-17871':
    command => 'sed -i "s/^        @parameters\[pname\] = \*args/        @parameters[pname], = *args/" base.rb',
    cwd     => "${site_ruby}/puppet/external/nagios/",
    onlyif  => 'test -f base.rb && grep -q "^        @parameters\[pname\] = \*args" base.rb',
    notify  => Exec[clean-host-cfgs],
  }
  exec { 'clean-host-cfgs':
    command => "find ${resourcedir} -type f -name '*.cfg' -delete",
    refreshonly => true,
  }
}

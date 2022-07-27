# @summary Configure nginx sites
#
# @param sites
class nginx (
  Hash[String, Hash[String, Any]] $sites = {},
) {
  package { 'nginx': }

  -> file { [
      '/etc/nginx',
      '/etc/nginx/sites',
    ]:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
  }

  file { '/etc/nginx/nginx.conf':
    ensure => file,
    source => 'puppet:///modules/nginx/nginx.conf',
    notify => Service['nginx'],
  }

  $sites.each |String $site, Hash $config| {
    nginx::site { $site:
      * => $config,
    }
  }

  service { 'nginx':
    ensure => running,
    enable => true,
  }
}

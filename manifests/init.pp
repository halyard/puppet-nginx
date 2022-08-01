# @summary Configure nginx sites
#
# @ports sets which ports to allow through the firewall for nginx
# @param sites
class nginx (
  Array[Integer] $ports = [433],
  Hash[String, Hash[String, Any]] $sites = {},
) {
  package { 'nginx': }

  -> file { [
      '/etc/nginx',
      '/etc/nginx/sites',
      '/etc/nginx/ssl',
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

  $ports.each |Integer $port| {
    firewall { "100 allow inbound ${port} for nginx":
      dport    => $port,
      proto    => 'tcp',
      action   => 'accept',
    }
  }

  service { 'nginx':
    ensure => running,
    enable => true,
  }
}

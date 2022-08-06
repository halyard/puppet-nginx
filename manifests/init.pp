# @summary Configure nginx sites
#
# @param ports sets which ports to allow through the firewall for nginx
# @param sites defines sites to create via hiera
class nginx (
  Array[Integer] $ports = [443],
  Hash[String, Hash[String, Any]] $sites = {},
) {
  package { 'nginx': }

  -> file { [
      '/etc/nginx',
      '/etc/nginx/ssl',
      '/etc/nginx/creds',
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

  file { '/etc/nginx/sites':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    notify  => Service['nginx'],
  }

  $ports.each |Integer $port| {
    firewall { "100 allow inbound ${port} for nginx":
      dport  => $port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

  service { 'nginx':
    ensure => running,
    enable => true,
  }
}

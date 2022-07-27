# @summary Configure nginx site
#
# @param proxy_target sets the target for the nginx proxy
# @param tls_account sets the TLS account config
# @param tls_challengealias sets the alias for TLS cert
# @param bind_addresses sets the IP for the site
# @param allow_ranges restricts access to the site based on source IP
# @param csp sets the content security policy for the site
# @param site sets the name of the site
define nginx::site (
  String $proxy_target,
  String $tls_account,
  Optional[String] $tls_challengealias = undef,
  Array[String] $bind_addresses = ['*', '[::]'],
  Array[String] $allow_ranges = [],
  String $csp = "default-src 'self' http: https: ws: wss: data: blob: 'unsafe-inline'; frame-ancestors 'self';",
  String $site = $title,
) {
  acme::certificate { $site:
    reloadcmd      => '/usr/bin/systemctl reload nginx',
    keypath        => "/etc/nginx/ssl/${site}.key",
    fullchainpath  => "/etc/nginx/ssl/${site}.crt",
    account        => $tls_account,
    challengealias => $tls_challengealias,
  }

  -> file { "/etc/nginx/sites/${site}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'http',
    mode    => '0640',
    content => template('nginx/site.conf.erb'),
    notify  => Service['nginx'],
  }
}

# @summary Configure nginx site without encryption
#
# @param proxy_target sets the target for the nginx proxy
# @param port sets the port to listen on
# @param bind_addresses sets the IP for the site
# @param allow_ranges restricts access to the site based on source IP
# @param csp sets the content security policy for the site
# @param proxy_params sets extra options to use in the proxy config
# @param custom_file sets a total override for the contents of the nginx config
# @param site sets the name of the site
define nginx::insecuresite (
  String $proxy_target,
  Integer $port = 80,
  Array[String] $bind_addresses = ['*', '[::]'],
  Array[String] $allow_ranges = [],
  String $csp = "default-src 'self' http: https: ws: wss: data: blob: 'unsafe-inline'; frame-ancestors 'self';",
  Hash[String, String] $proxy_params = {},
  Optional[String] $custom_file = undef,
  String $site = $title,
) {
  include nginx

  $contents = $custom_file ? {
    undef   => template('nginx/insecuresite.conf.erb'),
    default => $custom_file,
  }

  file { "/etc/nginx/sites/${site}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'http',
    mode    => '0640',
    content => $contents,
    notify  => Service['nginx'],
  }
}

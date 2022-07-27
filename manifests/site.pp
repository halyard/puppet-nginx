# @summary Configure nginx site
#
# @param proxy_target sets the target for the nginx proxy
# @param bind_address sets the IP for the site
# @param allow_ranges restricts access to the site based on source IP
# @param site sets the name of the site
define nginx::site (
  String $proxy_target,
  String $bind_address = '[::]',
  Array[String] $allow_ranges = [],
  String $site = $title,
) {
  file { "/etc/nginx/${site}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'http',
    mode    => '0640',
    content => template('nginx/site.conf.erb'),
    notify  => Service['nginx'],
  }
}

# @summary Configure nginx site
#
# @param site sets the name of the site
define wireguard::network (
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

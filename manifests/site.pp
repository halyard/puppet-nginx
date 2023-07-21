# @summary Configure nginx site
#
# @param proxy_target sets the target for the nginx proxy
# @param aws_access_key_id sets the AWS key to use for Route53 challenge
# @param aws_secret_access_key sets the AWS secret key to use for the Route53 challenge
# @param email sets the contact address for the certificate
# @param port sets the port to listen on
# @param bind_addresses sets the IP for the site
# @param allow_ranges restricts access to the site based on source IP
# @param csp sets the content security policy for the site
# @param proxy_params sets extra options to use in the proxy config
# @param custom_file sets a total override for the contents of the nginx config
# @param site sets the name of the site
# @param users sets basic auth users and hashed passwords
define nginx::site (
  String $proxy_target,
  String $aws_access_key_id,
  String $aws_secret_access_key,
  String $email,
  Integer $port = 443,
  Array[String] $bind_addresses = ['*', '[::]'],
  Array[String] $allow_ranges = [],
  String $csp = "default-src 'self' http: https: ws: wss: data: blob: 'unsafe-inline'; frame-ancestors 'self';",
  Hash[String, String] $proxy_params = {},
  Optional[String] $custom_file = undef,
  String $site = $title,
  Hash[String, String] $users = {},
) {
  include nginx

  $contents = $custom_file ? {
    undef   => template('nginx/site.conf.erb'),
    default => $custom_file,
  }

  $hook_script =  "#!/usr/bin/env bash
cp \$LEGO_CERT_PATH /etc/nginx/ssl/${site}.crt
cp \$LEGO_CERT_KEY_PATH /etc/nginx/ssl/${site}.key
/usr/bin/systemctl reload nginx"

  acme::certificate { $site:
    hook_script           => $hook_script,
    aws_access_key_id     => $aws_access_key_id,
    aws_secret_access_key => $aws_secret_access_key,
    email                 => $email,
  }

  -> file { "/etc/nginx/sites/${site}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'http',
    mode    => '0640',
    content => $contents,
    notify  => Service['nginx'],
  }

  if length($users) > 0 {
    file { "/etc/nginx/creds/${site}.htpasswd":
      ensure  => file,
      owner   => 'root',
      group   => 'http',
      mode    => '0640',
      content => template('nginx/htpasswd.erb'),
      notify  => Service['nginx'],
    }
  }
}

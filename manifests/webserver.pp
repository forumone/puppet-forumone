class forumone::webserver (
  $webserver      = "nginx",
  $port           = "8080",
  $platform       = $::platform,
  # Apache configuration
  $apache_startservers        = 8,
  $apache_minspareservers     = 5,
  $apache_maxspareservers     = 16,
  $apache_serverlimit         = 16,
  $apache_maxclients          = 16,
  $apache_maxrequestsperchild = 200,
  # nginx conf
  $nginx_conf     = [
    "client_max_body_size 200m",
    "client_body_buffer_size 2m",
    "set_real_ip_from 127.0.0.1",
    "real_ip_header X-Forwarded-For"],
  $nginx_worker_processes     = 1,
  # PHP configuration
  $php_fpm_listen = "/var/run/php-fpm.sock") {

  exec {'create_self_signed_sslcert': 
    command => "openssl req -newkey rsa:2048 -nodes -keyout /etc/pki/tls/private/localhost.key  -x509 -days 365 -out /etc/pki/tls/certs/localhost.crt -subj '/CN=${::fqdn}'", 
    cwd     => $certdir, 
    creates => [ "/etc/pki/tls/private/localhost.key", "/etc/pki/tls/certs/localhost.crt", ], 
    path    => ["/usr/bin", "/usr/sbin"] 
  } 

  if $webserver == 'apache' {
    class { "forumone::webserver::apache": }
  } elsif $webserver == 'nginx' {
    class { "forumone::webserver::nginx": }
  }
  
  create_resources('forumone::webserver::vhost', hiera('forumone::webserver::vhosts', {}))
}

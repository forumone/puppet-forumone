class forumone::wpcli ($url = 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar')
{
  exec { 'forumone::wpcli::download':
    command => "wget ${url} -O /usr/local/bin/wp --no-check-certificate",
    path    => '/usr/bin',
    creates => '/usr/local/bin/wp',
    }

  file { '/usr/local/bin/wp':
    ensure  => 'file',
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '755',
    require => [ Exec['forumone::wpcli::download'], Class['forumone::php'] ],
    }
}

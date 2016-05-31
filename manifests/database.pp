class forumone::database (
  $server        = true,
  $version       = '5.5',
  $manage_repo   = true,
  $configuration = {
    'mysqld/log_bin' => 'absent'
  }
) {
  file { '/etc/mysql': 
    ensure => 'directory'
  }

  file { '/etc/mysql/conf.d': 
    ensure => 'directory' 
  }

  package { 'nss': 
    ensure  => 'latest',
    before  => Class['percona::preinstall']
  }

  class { 'percona':
    server             => $server,
    percona_version    => $version,
    manage_repo        => $manage_repo,
    config_include_dir => '/etc/mysql/conf.d',
    configuration      => $configuration,
    require            => [ File['/etc/mysql/conf.d'], Package['nss'] ]
  }
  
  create_resources('percona::conf', hiera_hash('percona::conf', {
  }
  ))
}

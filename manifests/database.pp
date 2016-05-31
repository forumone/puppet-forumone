class forumone::database (
  $server        = true,
  $version       = '5.5',
  $manage_repo   = true,
  $configuration = {
    'mysqld/log_bin' => 'absent'
  }
) {
  package { 'nss':
    ensure             => 'latest'
  } ->
  file { '/etc/mysql': ensure => 'directory', } ->
  file { '/etc/mysql/conf.d': ensure => 'directory' } ->
  class { 'percona':
    server             => $server,
    percona_version    => $version,
    manage_repo        => $manage_repo,
    config_include_dir => '/etc/mysql/conf.d',
    configuration      => $configuration,
    require            => File['/etc/mysql/conf.d']
  }
  
  create_resources('percona::conf', hiera_hash('percona::conf', {
  }
  ))
}

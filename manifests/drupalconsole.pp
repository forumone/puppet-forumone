class forumone::drupalconsole ($url = 'https://drupalconsole.com/installer')
{
  exec { 'forumone::drupalconsole::download':
    command => "wget ${url} -O /usr/local/bin/drupal",
    path    => '/usr/bin',
    creates => '/usr/local/bin/drupal',
    }

  exec { 'forumone::drupalconsole::drupalinit':
    command => "drupal init",
    path    => ['/usr/bin','/usr/local/bin'],
    require => [ File['/usr/local/bin/drupal'], Class['forumone::php'] ],
    user    => vagrant,
    environment => ['HOME=/home/vagrant/'],
    }

  file { '/usr/local/bin/drupal':
    ensure  => 'file',
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '755',
    require => Exec ['forumone::drupalconsole::download']
    }
}

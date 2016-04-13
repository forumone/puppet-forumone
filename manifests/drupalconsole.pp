class forumone::drupalconsole ($url = 'https://drupalconsole.com/installer')
{
  exec { 'forumone::drupalconsole::download':
    command => "wget ${url} -O /usr/local/bin/drupal",
    path    => '/usr/bin',
    creates => '/usr/local/bin/drupal',
    }

  exec { 'forumone::drupalconsole::drupalinit':
    command => "/usr/local/bin/drupal init",
    path    => '/usr/bin',
    require => File['/usr/local/bin/drupal'],
    }

  file { '/usr/local/bin/drupal':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    require => Exec ['forumone::drupalconsole::download']
    }
}

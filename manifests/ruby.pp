class forumone::ruby (
  $version = "1.9.3",
  $user    = "vagrant",
  $group   = "vagrant",
) {

  $ruby_directory = "/home/${user}/.rbenv/versions/${version}"
  $ruby_download = "https://s3.amazonaws.com/pkgr-buildpack-ruby/current/centos-6/ruby-${version}.tgz"

  rbenv::plugin::rbenvvars { $user:
    user  => $user,
    group => $group,
    home  => "/home/${user}",
    root  => "/home/${user}/.rbenv"
  }

  exec { "forumone::ruby::download":
    command => "wget --directory-prefix=/tmp/vagrant-cache ${ruby_download}",
    path    => '/usr/bin',
    require => [ File["/tmp/vagrant-cache"] ],
    creates => "/tmp/vagrant-cache/ruby-${version}.tgz",
    timeout => 4800,
  }

  rbenv::install { $user:
    user => $user,
    group => $group,
    home  => "/home/${user}",
    root => "/home/${user}/.rbenv"
  } -> 
  file { "/home/${user}/.rbenv/versions":
    ensure  => "directory"
  } ->
  file { $ruby_directory:
    ensure  => "directory",
    require => Exec["rbenv::checkout ${user}"]       
  }

  # extract from the ruby archive
  exec { "forumone::ruby::extract":
    command => "tar -zxvf /tmp/vagrant-cache/ruby-${version}.tgz -C ${ruby_directory}",
    path    => ["/bin"],
    require => File[$ruby_directory],
    creates => "${ruby_directory}/bin",
  }
  
  file { "/home/${user}/Gemfile":
    ensure  => present,
    path    => "/home/${user}/Gemfile",
    owner   => $user,
    group   => $group,
    content => file('/vagrant/Gemfile'),
    backup  => false,
    require => Exec["forumone::ruby::extract"]
  }
  
  exec {"${user} bundle":
    command   => "bundle",
    cwd       => "/vagrant",
    user      => $user,
    group     => $group,
    path      => "/home/${user}/bin:/home/${user}/.rbenv/shims:/bin:/usr/bin",
    creates   => "/vagrant/Gemfile.lock",
    subscribe => File["/home/${user}/Gemfile"],
    require   => Rbenvgem["${user}/${version}/bundler/present"]
  }
}
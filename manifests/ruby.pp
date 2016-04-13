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
  
  # rbenv version
  file { $ruby_directory:
    ensure  => "directory"
  }
  
  # extract from the ruby archive
  exec { "forumone::ruby::extract":
    command => "tar -zxvf /tmp/vagrant-cache/ruby-${version}.tgz -C ${ruby_directory}",
    path    => ["/bin"],
    require => File[$ruby_directory],
    creates => "${ruby_directory}/bin",
  }
}

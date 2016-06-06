class forumone::nodejs ($modules = ["grunt-cli", "bower"], $version = 'v4.4.1') {
  class { '::nodejs':
    version	 => $version,
    make_install => false,
  }

  yumrepo { "devtools2":
    baseurl  => 'http://people.centos.org/tru/devtools-2/$releasever/$basearch/RPMS',
    descr    => "testing 2 devtools for CentOS $releasever",
    enabled  => 1,
    gpgcheck => 0
  }
  
  package { [ 'devtoolset-2-gcc', 'devtoolset-2-binutils', 'devtoolset-2-gcc-c++' ]: 
    require  => Yumrepo['devtools2']
  }

  package { 'scl-utils': 
    ensure   => 'latest'
  }

  file { '/etc/profile.d/devtoolset2.sh':
    ensure   => present,
    content  => template('forumone/nodejs/devtools2.erb')
  }
  
  package { $modules:
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs']
  }
}

class forumone::nodejs ($modules = ["grunt-cli", "bower"], $version = 'v4.4.1') {
  class { '::nodejs':
    version	 => $version,
    make_install => false,
  }

  yumrepo { "devtools2":
    baseurl  => "http://people.centos.org/tru/devtools-2/devtools-2.repo",
    descr    => "Devtools2",
    enabled  => 1,
    gpgcheck => 0
  }
  
  package { [ 'devtoolset-2-gcc', 'devtoolset-2-binutils', 'devtoolset-2-gcc' ]: 
    require  => Yumrepo['devtools2']
  }
  
  package { $modules:
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs']
  }
}

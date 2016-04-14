class forumone::solr ($version = "3.6.2") {
  $version_array = split($version, '[.]')
  $major_version = $version_array[0]
  $conf = "${major_version}.x"

  if $major_version == "4" {
    $filename = "solr-${version}"
    $initd_script = "solr_jetty_7.erb"
    $path = "/opt/${filename}/example/solr"
  } else {
    $filename = "apache-solr-${version}"
    $initd_script = "solr_jetty_6.erb"
    $path = "/opt/${filename}/example/multicore"
  }

  $url = "http://archive.apache.org/dist/lucene/solr/${version}/${filename}.tgz"

  # install the java package.
  package { ["java-1.7.0-openjdk"]: ensure => installed, }

  exec { "forumone::solr::download":
    command => "wget --directory-prefix=/tmp/vagrant-cache ${url}",
    path    => '/usr/bin',
    require => [ Package["java-1.7.0-openjdk"], File["/tmp/vagrant-cache"] ],
    creates => "/tmp/vagrant-cache/${filename}.tgz",
    timeout => 4800,
  }

  # extract from the solr archive
  exec { "forumone::solr::extract":
    command => "tar -zxvf /tmp/vagrant-cache/${filename}.tgz -C /opt",
    path    => ["/bin"],
    require => [Exec["forumone::solr::download"]],
    creates => "/opt/${filename}/LICENSE.txt",
  }

  file { "/etc/default/jetty":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "644",
    content => template("forumone/solr/etc_default.erb"),
    require => Exec["forumone::solr::extract"],
    notify  => Service['solr']
  }

  file { "/etc/init.d/solr":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "755",
    content => template("forumone/solr/${initd_script}"),
    require => Exec["forumone::solr::extract"],
  }

  service { 'solr':
    ensure    => running,
    enable    => true,
    require   => [Package["java-1.7.0-openjdk"], File["/etc/init.d/solr"], File['/etc/default/jetty']],
    pattern   => 'start.jar',
    hasstatus => false
  }

  file { '/var/log/solr':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    before => Service['solr']
  }

  if $major_version == 3 {
    file { "/opt/${filename}/example/etc/jetty-logging.xml":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => "755",
      content => template("forumone/solr/jetty_logging.erb"),
      require => Exec["forumone::solr::extract"],
      before  => Service['solr'],
      notify  => Service['solr']
    }

    concat { "${path}/solr.xml":
      owner   => "root",
      group   => "root",
      mode    => 644,
      require => Exec["forumone::solr::extract"],
      before  => Service['solr'],
      notify  => Service['solr']
    }

    concat::fragment { "solr_header":
      target  => "${path}/solr.xml",
      content => "<solr persistent='false'><cores adminPath='/admin/cores'>",
      order   => 01
    }

    concat::fragment { "solr_footer":
      target  => "${path}/solr.xml",
      content => "</cores></solr>",
      order   => 999
    }
  }
}

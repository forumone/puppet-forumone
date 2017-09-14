class forumone::varnish ($backend_port = "8080", $bind = "*:80", $cache_size = "256M", $template = undef) {
  case $::operatingsystem {
    /(?i:redhat|centos)/ : {
      yumrepo { "varnishcache_varnish30":
        baseurl  => 'https://packagecloud.io/varnishcache/varnish30/el/6/$basearch',
        descr    => "varnishcache_varnish30",
        enabled  => 1,
        priority => 1,
        gpgcheck => 0,
        repo_gpgcheck => 1,
        gpgkey => "https://packagecloud.io/varnishcache/varnish30/gpgkey",
        sslverify => 1,
        sslcacert => "/etc/pki/tls/certs/ca-bundle.crt"
      }
    }
  }

  if !$template {
    $file = '/etc/puppet/modules/forumone/templates/varnish/default.erb'
  }
  else {
    $file = $template
  }

  service { "varnish":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    status     => '/usr/sbin/service  varnish status | grep "is running"',
    require    => Package["varnish"],
  }

  package { "varnish":
    ensure  => installed,
    require => Yumrepo["varnishcache_varnish30"]
  }

  exec { "varnish-restart":
    command     => "/etc/init.d/varnish restart",
    refreshonly => true,
    require     => Package["varnish"],
  }

  file { "/etc/sysconfig/varnish":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "644",
    content => template("forumone/varnish/etc_default.erb"),
    require => Package["varnish"],
    notify  => Exec["varnish-restart"],
  }

  file { "/etc/varnish/default.vcl":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "644",
    content => inline_template(file($file)),
    require => Package["varnish"],
    notify  => Exec["varnish-restart"],
  }

  file { "/etc/varnish/acl.vcl":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "644",
    content => template("forumone/varnish/acl.erb"),
    require => Package["varnish"],
    notify  => Exec["varnish-restart"],
  }

  file { "/etc/varnish/backends.vcl":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => "644",
    content => template("forumone/varnish/backends.erb"),
    require => Package["varnish"],
    notify  => Exec["varnish-restart"],
  }
}

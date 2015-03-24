class mcommons(
  $install_info = "${::runner_home}/install_info.txt",
  $timestamp    = inline_template('<%= Time.new -%>'),
) {
  class { '::locales':
    default_value => 'en_US.UTF-8',
    available     => ['en_US.UTF-8 UTF-8', 'sv_SE.UTF-8 UTF-8']
  }

  file_line { 'Fix Puppets internal deprecation warnings':
    path  => '/etc/puppet/puppet.conf',
    line  => '# Removed deprecated templatedir variable',
    match => '^templatedir',
  }

  exec { 'apt-get-update':
    command => '/usr/bin/apt-get update'
  }

  package {[
      'autoconf', 'bison', 'build-essential', 'libssl-dev',
      'git', 'htop', 'unzip',
    ]:
    ensure  => installed,
    require => Exec['apt-get-update'],
  }

  class { '::ntp':
    servers  => ['ntp.malmo.se'],
    restrict => ['127.0.0.1'],
  }

  file { $install_info:
    mode    => '0600',
    content => "Puppet install details\n======================\nGenerated: ${timestamp}\n"
  }
}

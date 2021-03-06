class mcommons::wordpress(
  $tar_gz_url = 'https://sv.wordpress.org/latest-sv_SE.tar.gz',
  $table_prefix = 'wp_',
) {

  require ::mcommons::apache

  class { '::mcommons::wordpress::install':
    tar_gz_url => $tar_gz_url,
  }

  # Generate wp-config
  -> file { 'Generate Wordpress config file':
    path    => "${::doc_root}/wp-config.php",
    owner   => $::runner_name,
    group   => $::runner_group,
    mode    => '0644',
    content => template('mcommons/wp-config.php.erb'),
  }

  # Generate .htaccess
  -> file { 'Generate Wordpress .htaccess file':
    path    => "${::doc_root}/.htaccess",
    owner   => $::runner_name,
    group   => $::runner_group,
    mode    => '0644',
    content => template('mcommons/wp-htaccess.erb'),
  }

  # Create uploads dir
  -> file { "${::runner_home}/wordpress-uploads":
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
  }

  # Symlink uploads directory
  -> file { "${::doc_root}/wp-content/uploads":
    ensure => 'link',
    target => "${::runner_home}/wordpress-uploads",
    owner  => $::runner_name,
    group  => $::runner_group,
  }

  # Symlink themes directory
  -> file { "${::doc_root}/wp-content/themes":
    ensure => 'link',
    target => "${::app_home}/themes",
    owner  => $::runner_name,
    group  => $::runner_group,
  }

  # Symlink plugins directory
  -> file { "${::doc_root}/wp-content/plugins":
    ensure => 'link',
    target => "${::app_home}/plugins",
    owner  => $::runner_name,
    group  => $::runner_group,
  }

  cron { 'wordpress_cron_tasks':
    command => "cd ${::doc_root} && /usr/bin/php wp-cron.php >/dev/null 2>&1",
    user    => $::runner_name,
    minute  => '*/5'
  }
}

define mcommons::ruby::db_migrate() {
  require ::mcommons::ruby
  require ::mcommons::mysql

  exec { 'migrate database':
    command => 'bundle exec rake db:migrate',
    user    => $::runner_name,
    path    => $::runner_path,
    cwd     => $::app_home,
  }

  if $::db[create_test] {
    exec { 'migrate test database':
      command => 'bundle exec rake db:migrate RAILS_ENV=test',
      user    => $::runner_name,
      path    => $::runner_path,
      cwd     => $::app_home,
    }
  }
}

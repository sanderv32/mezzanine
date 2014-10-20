$username = 'sanoma'
$password = 'devops'
$project = 'mezz'

group { $username:
		ensure => present
}

user { 'sanoma':
		ensure => present,
		gid => $username,
		shell => '/bin/bash',
		home => '/home/sanoma',
		managehome => 'true',
        password => sha1($password)
}

exec {
    # Fix yum problem after installing epel
	'epel-https2http':
		command => 'sed -i.bak s/https/http/g /etc/yum.repos.d/epel.repo',
		path => '/bin/:/usr/bin/',
		onlyif => 'test ! -f /etc/yum.repos.d/epel.repo.bak',
		require => Package['epel-release.noarch'];

    'mezz':
        command => 'mezzanine-project mezz',
        user => $username,
        cwd => '/home/sanoma',
        path => '/bin/:/usr/bin/',
        onlyif => 'test ! -d /home/sanoma/mezz',
        require => [ Package['mezzanine'], User['sanoma'] ];

    'mezz-db':
        command => 'python manage.py createdb --noinput',
        user => $username,
        cwd => '/home/sanoma/mezz',
        path => '/bin/:/usr/bin/',
        onlyif => 'test ! -f /home/sanoma/mezz/dev.db',
        require => [ Exec['mezz'], User['sanoma'] ];

    'mezz-static':
        command => 'python manage.py collectstatic --noinput',
        user => $username,
        cwd => '/home/sanoma/mezz',
        path => '/bin/:/usr/bin/',
        onlyif => 'test ! -d /home/sanoma/mezz/static',
        require => [ Exec['mezz'], User['sanoma'] ];
}

file {
    '/home/sanoma':
        ensure => present,
        mode => 0755,
        require => User['sanoma'];

    '/home/sanoma/local_settings.py':
        ensure => present,
        owner => $username,
        group => $username,
        content => template('mezzanine/local_settings.py.erb'),
        require => Exec['mezz'];

    '/etc/gunicorn':
        ensure => 'directory';

    '/etc/gunicorn/gunicorn.conf':
        ensure => present,
        content => template('gunicorn/gunicorn.conf.erb'),
        require => [ Package['gunicorn'], File['/etc/gunicorn'] ];

    '/etc/init.d/gunicorn':
        ensure => present,
        mode => 0755,
        content => template('gunicorn/gunicorn.erb'),
        require => Package['gunicorn'];

    '/etc/nginx/conf.d/default.conf':
        ensure => present,
        content => template('nginx/default.conf.erb'),
        require => Package['nginx'];
}

service {
    'nginx':
        subscribe => File['/etc/nginx/conf.d/default.conf'],
        require => Package['nginx'],
        ensure => "running",
        enable => true;

    'gunicorn':
        subscribe => File['/home/sanoma/local_settings.py'],
        require => [ Package['gunicorn'], Package['mezzanine'], User['sanoma'] ],
        ensure => "running",
        enable => true;
}

package {
	'nginx':
		ensure => present,
		require => Exec['epel-https2http'];

	'python-pip.noarch':
		ensure => present,
		require => Exec['epel-https2http'];

	'epel-release.noarch':
		ensure => present;

	'python-devel':
		ensure => present;
				
	'checkout':
		provider => pip,
		ensure => present,
		require => [ Package['python-devel'], Package['python-pip.noarch'] ];

	'mezzanine':
		provider => pip,
		ensure => present,
		require => [ Package['python-devel'], Package['python-pip.noarch'] ];

    'gunicorn':
        provider => pip,
        ensure => present,
		require => [ Package['python-devel'], Package['python-pip.noarch'] ];
}

#  vim: set ts=4 sw=4 tw=0 et :

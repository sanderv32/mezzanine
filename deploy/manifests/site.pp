node "sanoma.local" {
    $username = 'sanoma'
    $password = 'devops'
    $project = 'mezz'

    group {
        $username:
    		ensure => present
    }

    user { 
        $username:
    		ensure => present,
    		gid => $username,
    		shell => '/bin/bash',
    		home => "/home/$username",
    		managehome => 'true',
            notify => Exec[$username];
    }

    exec {
        # Fix yum problem after installing epel
    	'epel-https2http':
    		command => 'sed -i.bak s/https/http/g /etc/yum.repos.d/epel.repo',
    		path => '/bin/:/usr/bin/',
    		onlyif => 'test ! -f /etc/yum.repos.d/epel.repo.bak',
    		require => Package['epel-release.noarch'];

        $username:
            command => '/bin/sh -c "echo devops" | passwd --stdin sanoma';
    }

    file {
        "/home/$username":
            ensure => present,
            mode => 0755,
            require => User[$username];

        '/etc/nginx/conf.d/default.conf':
            ensure => present,
            content => template('nginx/default.conf.erb'),
            require => Package['nginx'],
            notify => Service['nginx'];
    }

    package {
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
    }

    class { 
        'nginx':
            require => Exec['epel-https2http'];
    }

    class { 
        'mezzanine':
            user => $username,
            dir => "/home/$username",
            notify => Service['gunicorn'];
    }

    class {
        'gunicorn':
            user => $username,
            dir => "/home/$username",
            project => $project;
    }
}

#  vim: set ts=4 sw=4 tw=0 et :

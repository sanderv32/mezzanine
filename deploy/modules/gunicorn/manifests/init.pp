class gunicorn($project = 'mezzanine', $dir = '/home/mezzanine', $user = 'www-data')
{
    file {
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
    }

    service {
        'gunicorn':
            require => [ Package['gunicorn'], File['/etc/init.d/gunicorn'] ],
            ensure => 'running',
            enable => true;
    }

    package {
        'gunicorn':
            provider => pip,
            ensure => present,
            require => [ Package['python-devel'], Package['python-pip.noarch'] ];
    }
}

#  vim: set ts=4 sw=4 tw=0 et :

class mezzanine($project = 'mezz', $dir = '/home/mezzanine', $db='dev.db', $user = 'www-data')
{
    exec {
        'mezz':
            command => "sh -c \"cd $dir; mezzanine-project $project\"",
            user => $user,
            path => '/bin/:/usr/bin/',
            onlyif => "test ! -d $dir/$project",
            require => Package['mezzanine'];

        'mezz-db':
            command => "sh -c \"cd $dir/$project; python manage.py createdb --noinput\"",
            user => $user,
            path => '/bin/:/usr/bin/',
            onlyif => "test ! -f $dir/$project/$db",
            require => Exec['mezz'];

        'mezz-static':
            command => "sh -c \"cd $dir/$project; python manage.py collectstatic --noinput\"",
            user => $user,
            path => '/bin/:/usr/bin/',
            onlyif => "test ! -d $dir/$project/static",
            require => Exec['mezz'];
    }

    file {
        "$dir/local_settings.py":
            ensure => present,
            content => template('mezzanine/local_settings.py.erb'),
            require => Exec['mezz']; 
    }

    package {
    	'mezzanine':
    		provider => pip,
    		ensure => present,
    		require => [ Package['python-devel'], Package['python-pip.noarch'] ];
    }
}

#  vim: set ts=4 sw=4 tw=0 et :
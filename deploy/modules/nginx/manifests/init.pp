class nginx()
{
    package {
        'nginx':
            ensure => present
    }
    
    service {
        'nginx':
            require => Package['nginx'],
            ensure => "running",
            enable => true;
    }

}

#  vim: set ts=4 sw=4 tw=0 et :

class chrony {
    package { 'chrony':
        ensure => installed,
    }

    service { 'chronyd':
        ensure => running,
        enable => true,
        subscribe => File['/etc/chrony.conf'],
    }

    file { '/etc/chrony.conf':
        ensure  => file,
        require => Package['chrony'],
        notify  => Service['chronyd'],
        content => template('/templates/chrony.conf.erb'),
    }
}
class {'chrony':}

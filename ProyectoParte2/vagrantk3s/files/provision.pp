node default {
  class { 'vagrant_vm':
    hostname => $::hostname,
    nodeip   => $::nodeip,
    masterip => $::masterip,
    nodetype => $::nodetype,
  }
}

class vagrant_vm (
  String $hostname,
  String $nodeip,
  String $masterip,
  String $nodetype,
) {
  exec { 'set_timezone':
    command => 'timedatectl set-timezone Europe/Madrid',
    path    => '/bin:/usr/bin',
  }

  file { '/vagrant':
    ensure => 'directory',
    path   => '/vagrant',
  }

  host { 'hostname_entry':
    ensure       => present,
    name         => $nodeip,
    ip           => $nodeip,
    host_aliases => $hostname,
  }

  file { '/etc/hosts':
    ensure  => present,
    path    => '/etc/hosts',
    content => "192.168.0.149 m\n192.168.0.141 w1\n192.168.0.142 w2\n192.168.0.143 w3\n",
  }

  file { '/usr/local/bin/k3s':
    ensure  => present,
    source  => '/vagrant/k3s',
    mode    => '0755',
    require => File['/vagrant'],
  }

  if $nodetype == 'master' {
    exec { 'install_k3s_master':
      command => "env INSTALL_K3S_SKIP_DOWNLOAD=true /vagrant/install.sh server --token 'wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5' --flannel-iface enp0s8 --bind-address $nodeip --node-ip $nodeip --node-name $hostname --disable traefik --node-taint k3s-controlplane=true:NoExecute",
      path    => '/bin:/usr/bin',
      require => File['/usr/local/bin/k3s'],
    }

    exec { 'copy_k3s_yaml':
      command     => 'cp /etc/rancher/k3s/k3s.yaml /vagrant',
      path        => '/bin:/usr/bin',
      refreshonly => true,
      subscribe   => Exec['install_k3s_master'],
    }
  } else {
    exec { 'install_k3s_agent':
      command => "env INSTALL_K3S_SKIP_DOWNLOAD=true /vagrant/install.sh agent --server https://$masterip:6443 --token 'wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5' --node-ip $nodeip --node-name $hostname --flannel-iface enp0s8",
      path    => '/bin:/usr/bin',
      require => File['/usr/local/bin/k3s'],
    }
  }
}

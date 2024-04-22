# Comprobamos ipa-client instalado
package { ['ipa-client']:
  ensure => installed,
  notify => File['/etc/hosts'],
}

#Debemos modificar el fichero /etc/hosts
file { '/etc/hosts':
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode	=> '0644',
  source  => "/templates/hosts.conf.erb",
  subscribe => Package['ipa-client'],
  notify  => Exec['configure_ipa_client'],
}


exec { 'configure_ipa_client':
  command 	=> 'ipa-client-install --unattended --server=ipa1.1.e.ff.es.eu.org --domain=1.e.ff.es.eu.org --hostname=cliente3.1.e.ff.es.eu.org --principal=admin --password=lojusto2',
  path    	=> '/usr/sbin',
  subscribe   => File['/etc/hosts'],
  logoutput => true,
}


service { 'sssd':
  ensure	=> running,
  enable	=> true,
  subscribe => Exec['configure_ipa_client'],
}


# Modify the vlan212 connection
exec { 'modify_vlan1412':
  command => 'nmcli connection modify vlan1412 ipv6.dns \'2001:470:736b:e11::2\'',
  path	=> ['/usr/bin', '/usr/sbin'],
  require => Service['sssd'],
}

# Bring up the vlan212 connection
exec { 'up_vlan1412':
  command => 'nmcli connection up vlan1412',
  path	=> ['/usr/bin', '/usr/sbin'],
  require => Exec['modify_vlan1412'],
}

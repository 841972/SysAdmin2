# Define la clase para la configuración del cliente IPA
class cliente_ipa (
  $admin_user = 'admin',
  $ipa_server = 'ipa1.1.e.ff.es.eu.org ',
  $nfs_service = 'nfs/cliente3.1.e.ff.es.eu.org',
  $keytab_path = '/etc/krb5.keytab',
) {
  package { 'ipa-client':
    ensure => installed,
  }
  
  exec { 'sudo_kinit':
    command => "/usr/bin/sudo kinit ${admin_user}",
    unless  => '/usr/bin/sudo klist -s',
  }

  exec { 'kinit':
    command => "/usr/bin/kinit ${admin_user}",
    unless  => '/usr/bin/klist -s',
  }

  exec { 'ipa-getkeytab':
    command => "/usr/bin/sudo ipa-getkeytab -s ${ipa_server} -p ${nfs_service} -k ${keytab_path}",
    unless  => "/usr/bin/sudo klist -ket ${keytab_path} | grep -q ${nfs_service}",
    require => Exec['kinit'],
  }

  package { 'nfs-utils':
    ensure  => installed,
    require => Exec['ipa-getkeytab'],
  }


  exec { 'ipa-client-automount':
    #command => '/usr/bin/sudo ipa-client-automount --location=default',
    command => '/usr/bin/sudo mount -v -t nfs -o sec=krb5 nfs1.1.e.ff.es.eu.org:/exports/home /exports/home',
    #unless  => '/usr/bin/sudo grep -q "^+auto.master" /etc/auto.master',
    require => Package['nfs-utils'],
  }
}
class {'cliente_ipa':}

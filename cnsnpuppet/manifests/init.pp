class cnsnpuppet {
$iis_features = ['NET-Framework-Core','Web-Server','Web-WebServer','Web-Asp-Net45','Web-ISAPI-Ext','Web-ISAPI-Filter','NET-Framework-45-ASPNET','WAS-NET-Environment','Web-Http-Redirect','Web-Filtering','Web-Mgmt-Console','Web-Mgmt-Tools']

windowsfeature { $iis_features:
  ensure => present,
}

#
#sslcertificate { 'Install-PFX-Certificate' :
#  name       => 'mycert.pfx',
#  password   => 'password123',
#  location   => 'C:\',
#  thumbprint => '16792A55D3C6D5AF321D6A7FE1A5081441EFA171'
#}

exec { 'install-certificate':
  command  => '$($pass = "password123" | ConvertTo-SecureString -AsPlainText -Force;Import-PfxCertificate –FilePath C:\mycert.pfx cert:\localMachine\my -Password $pass)',
  provider => powershell,
}

iis::manage_app_pool {'my_application_pool':
    ensure                  => 'present',
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
    require                 => [
    WINDOWSFEATURE['Web-WebServer'],
    WINDOWSFEATURE['NET-Framework-45-ASPNET'],
  ],
}

iis::manage_site {'my_site':
    site_path   => 'c:/inetpub/website1/',
    site_id     => '51',
    port        => '89',
    ip_address  => '*',
    host_header => '',
    app_pool    => 'my_application_pool',
    require     => IIS::MANAGE_APP_POOL['my_application_pool'],
  }

iis::manage_binding {'my_site443':
    site_name              => 'my_site',
    protocol               => 'https',
    port                   => '443',
    ip_address             => '*',
    require                => [IIS::MANAGE_SITE['my_site'],EXEC['install-certificate']],
    certificate_thumbprint => '16792A55D3C6D5AF321D6A7FE1A5081441EFA171'
  }

file { 'c:/inetpub/website1/index.htm':
    ensure  => 'present',
    replace => 'yes',
    content => '<html><head><title>Test</title><body><h1>Hello from Cansin</h1><p>This is for test</p></body></head></html>',
    mode    => '0777',
    require => IIS::MANAGE_SITE['my_site'],
  }
}
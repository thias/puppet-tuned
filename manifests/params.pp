class tuned::params {

  # Two services, except on Fedora and RHEL/CentOS 7
  if ($facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '7') >= 0) {

    $default_profile = 'balanced'
    $tuned_services  = [ 'tuned' ]
    $active_profile  = 'active_profile'
    $config_path     = '/etc/tuned'
    $profile_path = versioncmp($facts['os']['release']['major'], '10') >= 0  ? {
      true  => "${config_path}/profiles",
      false => $config_path
    }

  } else {

    $default_profile = 'default'
    $tuned_services  = [ 'tuned', 'ktune' ]
    $config_path     = '/etc/tune-profiles'
    $profile_path    = $config_path
    $active_profile  = 'active-profile'

  }

}

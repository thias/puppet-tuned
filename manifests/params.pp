class tuned::params {

  # Two services, except on Fedora and RHEL/CentOS 7
  if ( ( $facts['os']['family'] == 'RedHat' ) and versioncmp($facts['os']['release']['major'], '7') >= 0 ) {

    $default_profile = 'balanced'
    $tuned_services  = [ 'tuned' ]
    $profile_path    = '/etc/tuned'
    $active_profile  = 'active_profile'

  } else {

    $default_profile = 'default'
    $tuned_services  = [ 'tuned', 'ktune' ]
    $profile_path    = '/etc/tune-profiles'
    $active_profile  = 'active-profile'

  }

}

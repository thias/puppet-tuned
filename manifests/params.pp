class tuned::params {

  # Two services, except on Fedora and RHEL/CentOS 7
  if ( $::operatingsystem == 'Fedora' ) or
    ( $::operatingsystem =~ /^(RedHat|CentOS|Scientific|OracleLinux|CloudLinux)$/ and versioncmp($::operatingsystemrelease, '7') >= 0 ) {

    $tuned_services  = [ 'tuned' ]
    $tuned_packages  = [ 'tuned' ]
    $profile_path    = '/etc/tuned'
    $active_profile  = 'active_profile'

  } else {

    $tuned_services  = [ 'tuned', 'ktune' ]
    $tuned_packages  = [ 'tuned' ]
    $profile_path    = '/etc/tune-profiles'
    $active_profile  = 'active-profile'

  }

}

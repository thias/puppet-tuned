class tuned::tuned (
  $profile = 'default',
  $source  = undef,
  $ensure  = present,
) {
  # Only if we are 'present'
  if $ensure != 'absent' {
  
    # One package
    package { 'tuned': ensure => $ensure }

    # Two services
    service { 'tuned' :
      enable    => true,
      ensure    => running,
      hasstatus => true,
      require   => Package['tuned'],
    }
    # Fedora doesn't have ktune thus it is an empty status  
    if $::operatingsystem != 'Fedora' {
      service { 'ktune' :
        enable    => true,
        ensure    => running,
        hasstatus => true,
        require   => Package['tuned'],
      }
    } else {
      service { 'ktune' : }
    }

    # Enable the chosen profile
    exec { "tuned-adm profile ${profile}":
      unless  => "grep -q -e '^${profile}\$' /etc/tune-profiles/active-profile",
      require => Package['tuned'],
      before  => [ Service['tuned'], Service['ktune'] ],
      path    => [ '/bin', '/usr/sbin' ],
      # No need to notify services, tuned-adm restarts them alone
    }

    # Install the profile's file tree if source is given
    if $source {
      file { "/etc/tune-profiles/${profile}":
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        ensure  => directory,
        recurse => true,
        purge   => true,
        source  => $source,
        # For the parent directory
        require => Package['tuned'],
        before  => Exec["tuned-adm profile ${profile}"],
      }
    }

  }

}

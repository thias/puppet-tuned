# Class: tuned
#
# The tuned adaptative system tuning daemon, introduced with Red Hat Enterprise
# Linux 6.
#
# Parameters:
#  $profile:
#    Profile to use, see 'tuned-adm list'. Default: 'default'
#  $source:
#    Puppet source location for the profile's files, used only for non-default
#    profiles. Default: none
#  $ensure:
#    Presence of tuned, 'absent' to disable and remove. Default: 'present'
#
class tuned (
  $profile = 'default',
  $source  = undef,
  $ensure  = present
) {

  # Support old facter versions without 'osfamily'
  if
    ( ( $::operatingsystem =~ /^(RedHat|CentOS|Scientific|OracleLinux|CloudLinux)$/ ) and
      ( $::operatingsystemrelease >= 6 )
    ) or
    ( ( $::operatingsystem == 'Fedora' ) and
      ( $::operatingsystemrelease >= 12 )
    )
  {

    # One package
    package { 'tuned': ensure => $ensure }

    # Only if we are 'present'
    if $ensure != 'absent' {

      # Two services, except on Fedora
      if $::operatingsystem != 'Fedora' {
        $tuned_services = [ 'tuned', 'ktune' ]
      } else {
        $tuned_services = [ 'tuned' ]
      }
      service { $tuned_services:
        enable    => true,
        ensure    => running,
        hasstatus => true,
        require   => Package['tuned'],
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

  } else {

    # Report to both the agent and the master that we don't do anything
    $message = "${::operatingsystem} ${::operatingsystemrelease} not supported by the tuned module"
    notice($message)
    notify { $message: withpath => true }

  }

}


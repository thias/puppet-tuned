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
#
class tuned (
  $profile = 'default',
  $source = undef,
) {

  # One package, two services
  package { 'tuned': ensure => installed }
  service { [ 'tuned', 'ktune' ]:
    enable    => true,
    ensure    => running,
    hasstatus => true,
    require   => Package['tuned'],
  }

  # Enable the chosen profile
  exec { "/usr/sbin/tuned-adm profile ${profile}":
    unless => "/bin/grep -q -e '^${profile}\$' /etc/tune-profiles/active-profile",
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
    }
  }

}


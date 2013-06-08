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
  $ensure  = present,
) {

  # As far as I know, at this time only Red Hat variations supported tuned.
  if $::osfamily == 'RedHat' {
      # Find out which Red Hat variation
      case $::operatingsystem {
        # This isn't a complete list of Red Hat derivatives, but it is what I
        # have availible to test on.
        'RedHat', 'CentOS', 'Scientific', 'OracleLinux': {
          # Only versions greater then Red Hat 6 are supported.
          if ( $::operatingsystemmajrelease >= 6 ) or ( $::lsbmajdistrelease >= 6 ) {
            # If everything checks out, pass profiles on to do the real work.
            class { 'tuned::tuned': profile => $profile, source=>$source, ensure=>$ensure, }
          } else {
            # Wrong version
            class { 'tuned::error' : errormsg => 'WrongVersion',}
          }
        }
        # Fedora is a bit different. Tuned was packaged in 12. While not
        # advisable to run old versions of Fedora, it happens.
        'Fedora': {
          if ( $::operatingsystemrelease >= 12 ) or ( $::lsbmajdistrelease >= 12 ) {
            # If everything checks out, pass profiles on to do the real work.
            class { 'tuned::tuned': profile => $profile, source=>$source, ensure=>$ensure,}
          } else {
            # Wrong version
            class { 'tuned::error' : errormsg => 'WrongVersion',}
          }
        }
        # Don't recognize this version of Red Hat.
        default: { class { 'tuned::error' : errormsg => 'WrongVariation',} }
      }
  } else {
        # This isn't a Red Hat variation.
	class { 'tuned::error' : errormsg => 'WrongOS', }
  }

}

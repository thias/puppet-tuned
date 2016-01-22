# Class: tuned
#
# The tuned adaptative system tuning daemon, introduced with Red Hat Enterprise
# Linux 6.
#
# Parameters:
#  $ensure:
#    Presence of tuned, 'absent' to disable and remove. Default: 'present'
#  $profile:
#    Profile to use, see 'tuned-adm list'. Default: 'default'
#  $source:
#    Puppet source location for the profile's files, used only for non-default
#    profiles. Default: none
#
class tuned (
  $service_ensure = 'running',
  $service_enable = true,
  $package_ensure = 'present',
  $profile        = undef,
  $source         = undef,
  $tuned_packages = $::tuned::params::tuned_packages,
  $tuned_services = $::tuned::params::tuned_services,
  $profile_path   = $::tuned::params::profile_path,
  $active_profile = $::tuned::params::active_profile,
) inherits ::tuned::params {

  # Support old facter versions without 'osfamily'
  if ( $::operatingsystem == 'Fedora' ) or
    ( $::operatingsystem =~ /^(RedHat|CentOS|Scientific|OracleLinux|CloudLinux)$/ and versioncmp($::operatingsystemrelease, '6') >= 0 ) {

    # One package only if not stopped
    package { $tuned_packages : ensure => $package_ensure }

    service { $tuned_services:
      ensure    => $service_ensure,
      enable    => $service_enable,
      hasstatus => true,
      require   => Package[$tuned_packages],
    }

    # Install the profile's file tree if source is given
    if $source {
      file { "${profile_path}/${profile}":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        # This magically becomes 755 for directories
        mode    => '0644',
        recurse => true,
        purge   => true,
        source  => $source,
        # For the parent directory
        require => Package[$tuned_packages],
        before  => Anchor['profile_downloaded'],
        notify  => Service[$tuned_services],
      }
    }

    anchor { 'profile_downloaded': }

    if $profile {
      file { 'current_profile' :
        ensure  => file,
        path    => "${profile_path}/${active_profile}",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${profile}\n",
        # notify is not needed. daemon monitors file by its own
        require => Anchor['profile_downloaded'],
        notify  => Service[$tuned_services],
      }
    }

  } else {

    # Report to both the agent and the master that we don't do anything
    $message = "${::operatingsystem} ${::operatingsystemrelease} not supported by the tuned module"
    notice($message)
    notify { $message: withpath => true }

  }

}


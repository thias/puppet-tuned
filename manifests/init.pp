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
#  $scripts:
#    Set to true if the source profile contains scripts, in order for all files
#    to become executable (including tuned.conf, unfortunately).
#  $settings:
#    Hash settings to create tuned.conf profile's file. Default: undef
#
class tuned (
  $ensure         = 'present',
  $profile        = $::tuned::params::default_profile,
  $source         = undef,
  $scripts        = false,
  $settings       = undef,
  $tuned_services = $::tuned::params::tuned_services,
  $profile_path   = $::tuned::params::profile_path,
  $active_profile = $::tuned::params::active_profile,
) inherits ::tuned::params {

  if ( ( $facts['os']['family'] == 'RedHat' ) and versioncmp($::operatingsystemrelease, '6') >= 0 ) {

    # One package
    package { 'tuned': ensure => $ensure }

    # Only if we are 'present'
    if $ensure != 'absent' {

      # Ensure tuned is started before some DBMS, for when it's used to disable
      # transparent hugepages
      if $::service_provider == 'systemd' {
        file { '/etc/systemd/system/tuned.service.d':
          ensure => 'directory',
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
        }
        file { '/etc/systemd/system/tuned.service.d/before.conf':
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => "[Unit]\nBefore=mariadb.service mongod.service redis-server.service\n",
        }
        ~> exec { 'tuned systemctl daemon-reload':
          command     => 'systemctl daemon-reload',
          path        => $::path,
          refreshonly => true,
          before      => Service['tuned'],
        }
      }
      # Enable the service
      service { $tuned_services:
        ensure    => 'running',
        enable    => true,
        hasstatus => true,
        require   => Package['tuned'],
      }

      # Enable the chosen profile
      exec { "tuned-adm profile ${profile}":
        unless  => "grep -q -e '^${profile}\$' ${profile_path}/${active_profile}",
        require => Service['tuned'],
        path    => [ '/sbin', '/bin', '/usr/sbin' ],
        # No need to notify services, tuned-adm restarts them alone
      }

      if $settings and $source {
        fail('source & settings parameters are exclusive.')
      }

      if $source {
        # Install the profile's file tree if source is given
        file { "${profile_path}/${profile}":
          ensure  => 'directory',
          owner   => 'root',
          group   => 'root',
          mode    => $scripts ? {
            true  => '0755',
            # This magically becomes 755 for directories
            false => '0644',
          },
          recurse => true,
          purge   => true,
          source  => $source,
          # For the parent directory
          require => Package['tuned'],
          before  => Exec["tuned-adm profile ${profile}"],
          notify  => Service[$tuned_services],
        }
      } elsif $settings {
        # Generate & install the profile according to the settings parameter
        validate_hash($settings)
        file { "${profile_path}/${profile}":
          ensure  => 'directory',
          owner   => 'root',
          group   => 'root',
          mode    => '0755',
          require => Package['tuned'];
        }
        file { "${profile_path}/${profile}/tuned.conf":
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('tuned/tuned.conf.erb'),
          before  => Exec["tuned-adm profile ${profile}"],
          notify  => Service[$tuned_services];
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

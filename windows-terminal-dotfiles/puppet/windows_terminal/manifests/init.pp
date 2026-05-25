class windows_terminal {
  $local_state = "${::env['LOCALAPPDATA']}\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState"

  file { $local_state:
    ensure => directory,
  }

  file { "${local_state}\\settings.json":
    ensure  => file,
    source  => "puppet:///modules/windows_terminal/settings.json",
    replace => true,
  }
}

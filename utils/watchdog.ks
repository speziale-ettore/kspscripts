//
// watchdog.ks: watchdog utils.
//

local do_reset is false.

on ag10 {
  set do_reset to true.
  preserve.
}

function soft_reset {
  parameter mission.

  if do_reset {
    terminate(mission).
    reboot.
  }
}

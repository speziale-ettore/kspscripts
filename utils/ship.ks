//
// ship.ks: ship functions.
//

function ship_yaw {
  return 90 - vang(ship:velocity:surface, ship:facing:starvector).
}

function ship_pitch {
  return 90 - vang(ship:up:forevector, ship:facing:forevector).
}

function ship_roll {
  return -90 + vang(ship:up:forevector, ship:facing:starvector).
}

function ship_family {
  local n is ship:name:indexof(" ").
  if n = -1 {
    set n to ship:length.
  }
  return ship:name:substring(0, n).
}

function ship_science {
  local science is list().

  for part in ship:partstagged(ship_family() + "-science") {
    science:add(part:getmodule("ModuleScienceExperiment")).
  }

  return science.
}

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

function ship_x {
  return ship:facing:forevector:normalized.
}

function ship_y {
  return ship:facing:upvector:normalized.
}

function ship_z {
  return ship:facing:starvector:normalized.
}

function ship_aoa {
  local aoa is -360.

  for wing in ship_wings() {
    set aoa to max(aoa, vang(ship:velocity:surface, wing:facing:forevector)).
  }

  return aoa.
}

function ship_family {
  local n is ship:name:indexof(" ").
  if n = -1 {
    set n to ship:name:length.
  }
  return ship:name:substring(0, n).
}

function ship_haspart {
  parameter tag.
  return not ship:partstagged(tag):empty.
}

function ship_cpu {
  parameter name.

  local cpu is false.
  if ship_haspart(ship_family() + "-" + name + "-cpu") {
    set cpu to processor(ship_family() + "-" + name + "-cpu").
  } else if ship_haspart(name + "-cpu") {
    set cpu to processor(name + "-cpu").
  } else {
    set cpu to processor(ship_family() + "-cpu").
  }

  return cpu.
}

function ship_mfd_cpu {
  return ship_cpu("mfd").
}

function ship_hud_cpu {
  return ship_cpu("hud").
}

function ship_engines {
  local engines is list().

  for part in ship:partstagged(ship_family() + "-engine") {
    engines:add(part).
  }

  return engines.
}

function ship_wings {
  local wings is list().

  for wing in ship:partstagged(ship_family() + "-wing") {
    wings:add(wing).
  }

  return wings.
}

function ship_flaps {
  local flaps is list().

  for flap in ship:partstagged(ship_family() + "-flap") {
    flaps:add(flap:getmodule("ModuleControlSurface")).
  }

  return flaps.
}

function ship_science {
  local science is list().

  for part in ship:partstagged(ship_family() + "-core") {
    if part:hasmodule("ModuleScienceExperiment") {
      science:add(part:getmodule("ModuleScienceExperiment")).
    }
  }
  for part in ship:partstagged(ship_family() + "-science") {
    if part:hasmodule("ModuleScienceExperiment") {
      science:add(part:getmodule("ModuleScienceExperiment")).
    }
  }

  return science.
}

local antennas is lexicon().
set antennas["Communotron 16-S"] to lexicon("bandwidth", 3.3333,
                                            "transmit_cost", 20).
set antennas["Communotron 16"] to lexicon("bandwidth", 3.3333,
                                          "transmit_cost", 20).

function ship_bandwidth {
  local bandwidth is 1e3.
  for part in ship:partstagged(ship_family() + "-antenna") {
    set bandwidth to min(bandwidth, antennas[part:title]["bandwidth"]).
  }
  return bandwidth.
}

function ship_transmit_cost {
  local transmit_cost is 0.
  for part in ship:partstagged(ship_family() + "-antenna") {
    set transmit_cost to max(transmit_cost,
                             antennas[part:title]["transmit_cost"]).
  }
  return transmit_cost.
}



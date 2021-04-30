//
// ship.ks: ship functions.
//

function ship_yaw {
  if ship:velocity:surface:mag < 0.01 {
    return 0.
  }

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
  if ship:velocity:surface:mag < 0.01 {
    return 360.
  }

  local aoa is -360.

  for wing in ship_wings() {
   local aoaw is arctan2(vdot(wing:facing:topvector, ship:velocity:surface),
                         vdot(wing:facing:forevector, ship:velocity:surface)).
   set aoa to max(aoa, aoaw).
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

function ship_navigation_lights {
  local navigation_lights is list().

  for navigation_light in ship:partstagged(ship_family() + "-navlight") {
    navigation_lights:add(navigation_light:getmodule("ModuleLight")).
  }

  return navigation_lights.
}

function ship_has_acc_sensor {
  return not ship:partstitled("Double-C Seismic Accelerometer"):empty.
}

function ship_has_pres_sensor {
  return not ship:partstitled("PresMat Barometer"):empty.
}

function ship_has_temp_sensor {
  return not ship:partstitled("2HOT Thermometer"):empty.
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



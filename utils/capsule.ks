//
// capsule.ks: capsule functions.
//

function _capsule_aero_min_pressure {
  parameter suffix.
  local min_pressure is 1.

  for part in ship:partstagged(ship_family() + "-" + suffix) {
    local chute is part:getmodule("ModuleParachute").
    set min_pressure to min(min_pressure, chute:getfield("min pressure")).
  }

  return min_pressure.
}

function capsule_drags_min_pressure {
  return _capsule_aero_min_pressure("drag").
}

function capsule_chutes_min_pressure {
  return _capsule_aero_min_pressure("chute").
}

function drop_heatshield {
  for shield in ship:partstagged(ship_family() + "-shield") {
    shield:getmodule("ModuleDecouple"):doaction("jettison heat shield", true).
  }
}

function make_capsule_suborbital_steering {
  function _steering {
    if ship:status = "FLYING" {
      if ship:verticalspeed >= 0 {
        return lookdirup(ship:srfprograde:forevector, body:position).
      } else {
        return ship:srfretrograde.
      }
    }

    if ship:status = "SUB_ORBITAL" {
      if ship:verticalspeed >= 0 {
        return lookdirup(ship:prograde:forevector, body:position).
      } else {
        return lookdirup(ship:retrograde:forevector, body:position).
      }
    }
  }

  return _steering@.
}

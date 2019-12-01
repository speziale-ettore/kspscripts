//
// capsule.ks: capsule functions.
//

function capsule_chutes_min_pressure {
  local min_pressure is 1.

  for part in ship:partstagged(ship_family() + "-chute") {
    local chute is part:getmodule("ModuleParachute").
    set min_pressure to min(min_pressure, chute:getfield("min pressure")).
  }

  return min_pressure.
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

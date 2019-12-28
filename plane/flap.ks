//
// flap.ks: automatic flap controller.
//

include("math/clamp.ks").
include("utils/ship.ks").

function flap_get_angle {
  parameter flap.
  return flap:getfield("deploy angle").
}

function flap_set_angle {
  parameter flap.
  parameter angle.
  return flap:setfield("deploy angle", angle).
}

function make_flap_controller {
  parameter ext_speed.
  parameter ret_speed.
  parameter max_angle.

  local flaps is ship_flaps().
  local auto_flaps is true.

  local m is -max_angle / (ret_speed - ext_speed).
  local q is -m * ret_speed.

  function _flap {
    parameter mission.

    local auto_angle is clamp(m * ship:velocity:surface:mag + q, 0, max_angle).
    local delta_angle is 0.

    if not core:messages:empty {
      local msg is core:messages:peek().

      if msg:content = "toggle_auto_flaps" {
        set auto_flaps to not auto_flaps.
        core:messages:pop().
      } else if msg:content = "less_flaps" {
        set delta_angle to -1.
        core:messages:pop().
      } else if msg:content = "more_flaps" {
        set delta_angle to 1.
        core:messages:pop().
      }
    }

    for flap in flaps {
      if auto_flaps {
        flap_set_angle(flap, auto_angle).
      } else {
        flap_set_angle(flap,
                       clamp(flap_get_angle(flap) + delta_angle, 0, max_angle)).
      }
    }
  }

  return _flap@.
}

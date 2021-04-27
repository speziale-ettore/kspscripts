//
// flap.ks: automatic flap controller.
//

include("control/rate_limiter.ks").
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
  parameter min_aoa.
  parameter max_aoa.
  parameter min_speed.
  parameter max_angle.

  local flaps is ship_flaps().
  local auto_flaps is true.

  local m is max_angle / (max_aoa - min_aoa).
  local q is -m * min_aoa.

  local rate_limiters is list().
  for flap in flaps {
    rate_limiters:add(make_rate_limiter(2 * max_angle,
                                        time:seconds, flap_get_angle(flap))).
  }

  function _flap {
    parameter mission.

    local auto_angle is clamp(m * ship_aoa() + q, 0, max_angle).
    if (ship:velocity:surface:mag < min_speed)
      set auto_angle to max_angle.
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

    from {local i is 0.} until i = flaps:length step {set i to i + 1.} do {
      local angle is 0.
      if auto_flaps {
        set angle to auto_angle.
      } else {
        set angle to clamp(flap_get_angle(flaps[i]) + delta_angle,
                           0, max_angle).
      }
      set angle to rate_limiter_update(rate_limiters[i], time:seconds, angle).
      flap_set_angle(flaps[i], angle).
    }
  }

  return _flap@.
}

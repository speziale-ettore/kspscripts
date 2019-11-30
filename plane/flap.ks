//
// flap.ks: automatic flap controller.
//

include("math/clamp.ks").

function make_flap_controller {
  parameter ext_speed.
  parameter ret_speed.
  parameter max_angle.

  local flaps is list().
  for flap in ship:partstagged("flap") {
    flaps:add(flap:getmodule("ModuleControlSurface")).
  }

  local m is -max_angle / (ret_speed - ext_speed).
  local q is -m * ret_speed.

  function _flap {
    parameter mission.

    local angle is clamp(m * ship:velocity:surface:mag + q, 0, max_angle).
    for flap in flaps {
      flap:setfield("deploy angle", angle).
    }
  }

  return _flap@.
}

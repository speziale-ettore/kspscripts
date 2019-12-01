//
// rocket.ks: rocket functions.
//

include("utils/ship.ks").
include("utils/navigation.ks").

function make_rocket_ascending_steering {
  parameter inclination.
  parameter altitude.

  local pitch_a is 0.
  local pitch_b is 0.
  local pitch_direction is heading(inclination, 80).
  local pitch_heading is dir_heading(pitch_direction).

  local _prev_state is 0.
  local _cur_state is 0.

  function _steering {
    if _cur_state = 0 {
      if ship:verticalspeed >= 80 {
        notify_info("start pitching").
        set _cur_state to 1.
      }
      set _prev_state to 0.
      return heading(0, 90).
    } if _cur_state = 1 {
      if _prev_state = 1 and
         abs(steeringmanager:angleerror) < 3 and
         abs(steeringmanager:rollerror) < 3 {
        notify_info("pitching done").
        set _cur_state to 2.
      }
      set _prev_state to 1.
      return lookdirup(pitch_direction:forevector, body:position).
    } if _cur_state = 2 {
      if _prev_state = 2 and eta:apoapsis >= 90 {
        notify_info("gravity turn done").
        set pitch_a to ship_pitch() / (ship:altitude^2 - altitude^2).
        set pitch_b to -pitch_a * altitude^2.
        set _cur_state to 3.
      }
      set _prev_state to 2.
      return lookdirup(ship:srfprograde:forevector, body:position).
    } if _cur_state = 3 {
      if _prev_state = 3 and ship:altitude >= altitude {
        notify_info("acceleration altitude achieved").
        set _cur_state to 4.
      }
      set _prev_state to 3.
      return lookdirup(heading(pitch_heading,
                               pitch_a * ship:altitude^2 + pitch_b):forevector,
                       body:position).
    } else {
      set _prev_state to 4.
      return lookdirup(heading(pitch_heading, 0):forevector, body:position).
    }
  }

  return _steering@.
}

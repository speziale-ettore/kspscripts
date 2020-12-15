//
// blackbox.ks: flight data recorder.
//

include("utils/ship.ks").

function make_blackbox {
  local log_path is "0:/log/" + ship:name + ".dat".

  local logging is false.
  local last_time is -1.

  if exists(log_path) {
    deletepath(log_path).
  }

  function _blackbox {
    parameter mission.

    if not core:messages:empty {
      local msg is core:messages:peek().

      if msg:content = "toggle_logging" {
        set logging to not logging.
        core:messages:pop().
      }
    }

    if logging and time <> last_time {
      local msg is "".
      set msg to msg + time:seconds.
      set msg to msg + " " + ship_pitch()
                     + " " + ship_roll()
                     + " " + ship_yaw().
      set msg to msg + " " + ship_aoa().
      set msg to msg + " " + ship:velocity:surface:x +
                     + " " + ship:velocity:surface:y +
                     + " " + ship:velocity:surface:z.
      log msg to log_path.
      set last_time to time.
    }
  }

  return _blackbox@.
}

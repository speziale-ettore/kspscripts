//
// watchdog.ks: watchdog utils.
//

include("utils/ship.ks").

function make_watchdog_replier {
  function _replier {
    parameter mission.

    if core:messages:empty {
      return.
    }

    local msg is core:messages:peek().

    if msg:content:startswith("ping-") {
      local cpu is msg:content:substring(5, msg:content:length - 5).
      if ship_haspart(cpu) {
        processor(cpu):connection:sendmessage("pong-" + core:tag).
      }
      core:messages:pop().
    }
  }

  return _replier@.
}

//
// navigation-lights.ks: science mfd.
//

function toggle_navigation_lights {
  parameter navigation_lights.

  for navigation_light in navigation_lights {
    if navigation_light:getfield("light status") = "Nominal" {
      navigation_light:doaction("toggle light", false).
    } else {
      navigation_light:doaction("toggle light", true).
    }
  }
}

function make_navigation_lights {
  parameter navigation_lights is ship_navigation_lights().

  function _messages {
    parameter mission.

    if core:messages:empty {
      return.
    }

    local msg is core:messages:peek().
    if not msg:content:istype("string") {
      return.
    }

    if msg:content = "toggle_navigation_lights" {
      toggle_navigation_lights(navigation_lights).
      core:messages:pop().
    }
  }

  return _messages@.
}

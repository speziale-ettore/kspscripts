//
// sabre-cpu: sabre plane,
//

include("utils/mission-runner.ks").
include("plane/flap.ks").
include("utils/navigation-lights.ks").
include("utils/science.ks").
include("utils/watchdog.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  switch_to_runmode(mission, "loop").
}

function _loop {
  parameter mission.
}

//
// Script entry point.
//

local sequence is lexicon().
sequence:add("launch", _launch@).
sequence:add("loop", _loop@).

local events is lexicon().
events:add("flap", make_flap_controller(6, 8, 110, 10)).
events:add("navigation_lights", make_navigation_lights()).
events:add("science", make_science()).
events:add("watchdog", make_watchdog_replier()).

run_mission(sequence, events).

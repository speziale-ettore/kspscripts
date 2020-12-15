//
// sabre-cpu: sabre plane,
//

include("utils/mission-runner.ks").
include("plane/flap.ks").
include("utils/blackbox.ks").
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
events:add("watchdog", make_watchdog_replier()).
events:add("blackbox", make_blackbox()).

run_mission(sequence, events).

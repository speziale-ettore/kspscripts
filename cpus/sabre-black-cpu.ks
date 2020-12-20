//
// sabre-black-cpu.ks: blackbox cpu.
//

include("utils/mission-runner.ks").
include("utils/blackbox.ks").
include("utils/watchdog.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.
}

//
// Script entry point.
//

local sequence is lexicon().
sequence:add("launch", _launch@).

local events is lexicon().
events:add("watchdog", make_watchdog_replier()).
events:add("blackbox", make_blackbox()).

run_mission(sequence, events).

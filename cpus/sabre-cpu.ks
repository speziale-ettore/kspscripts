//
// sabre-cpu: sabre plane,
//

include("utils/mission-runner.ks").
include("plane/flap.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  sas on.

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
events:add("flap", make_flap_controller(110, 120, 10)).

run_mission(sequence, events).

//
// sabrehud-cpu: sabre head up display,
//

include("utils/mission-runner.ks").
include("utils/mfd.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local science is make_first_science_mfd_page(ship_science()).

  mfd_init(science).

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
events:add("mfd", mfd_update@).
events:add("science", make_science()).

run_mission(sequence, events).

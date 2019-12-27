//
// scout-cpu: scout cpu,
//

include("utils/mission-runner.ks").
include("utils/mfd.ks").
include("utils/navigation.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local navigation is make_first_navigation_mfd_page(all_waypoints()).
  local science is make_science_mfd_page(ship_science()).

  set_next_mfd_page(navigation, science).
  set_next_mfd_page(science, navigation).

  mfd_init(navigation).

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

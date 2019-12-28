//
// sabrehud-cpu: sabre head up display,
//

include("utils/mission-runner.ks").
include("utils/mfd.ks").
include("utils/navigation.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local engineering is make_first_engineering_mfd_page(ship_engines(),
                                                       ship_flaps()).
  local navigation is make_navigation_mfd_page(all_waypoints()).
  local science is make_science_mfd_page(ship_science()).

  set_next_mfd_page(engineering, navigation).
  set_next_mfd_page(navigation, science).
  set_next_mfd_page(science, engineering).

  mfd_init(engineering).

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

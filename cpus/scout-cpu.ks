//
// scout-cpu: scout cpu,
//

include("utils/mission-runner.ks").
include("utils/drive-director.ks").
include("utils/hud.ks").
include("utils/mfd.ks").
include("utils/navigation-mfd.ks").
include("utils/science-mfd.ks").
include("utils/navigation.ks").
include("utils/watchdog.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local courses is all_ground_courses().

  drive_director_init(courses).

  local navigation is make_first_navigation_mfd_page(courses).
  local science is make_science_mfd_page(ship_science()).

  set_next_mfd_page(navigation, science).
  set_next_mfd_page(science, navigation).

  mfd_init(navigation).

  hud_init_1d(10, 1, 0.25).

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
events:add("auto", drive_director_update@).
events:add("mfd", mfd_update@).
events:add("hud", hud_update@).
events:add("science", make_science()).
events:add("watchdog", make_watchdog_replier()).

run_mission(sequence, events).

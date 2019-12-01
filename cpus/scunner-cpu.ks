//
// scunner-cpu: scunner icbm,
//

include("utils/mission-runner.ks").
include("utils/rocket.ks").
include("utils/ship.ks").

local do_launch is false.
on ag9 {
  set do_launch to true.
}

//
// Mission sequence.
//

function _launch {
  parameter mission.

  if not do_launch {
    return.
  }

  notify_info("ignition").
  stage.

  local str is make_rocket_ascending_steering(-30, 10000).
  lock steering to str().
  rcs on.
  wait 2.

  notify_info("launch").
  stage.

  switch_to_runmode(mission, "meco").
}

function _meco {
  parameter mission.

  if ship:solidfuel > 0.1 {
    return.
  }

  notify_info("meco").

  rcs off.
  unlock steering.
  wait 2.
  processor(ship_family() + "-cpu"):connection:sendmessage("detach").

  switch_to_runmode(mission, "sink").
}

function _sink {
  parameter mission.
}

//
// Script entry point.
//

local sequence is lexicon().
sequence:add("launch", _launch@).
sequence:add("meco", _meco@).
sequence:add("sink", _sink@).

local events is lexicon().

run_mission(sequence, events).

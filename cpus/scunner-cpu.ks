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

  local str is 0.
  if ship_haspart("scunner-te") {
    set str to make_rocket_ascending_steering(135, 100000).
  } else if ship_haspart("scunner-se") {
    set str to make_rocket_ascending_steering(150, 50000).
  } else {
    set str to make_rocket_ascending_steering(120, 10000).
  }

  lock steering to str().
  rcs on.
  wait 2.

  notify_info("launch").
  stage.

  switch_to_runmode(mission, "meco").
}

function _meco {
  parameter mission.

  if stage:solidfuel > 0.1 {
    return.
  }

  notify_info("meco").

  if ship_haspart("scunner-se") {
    stage.
    wait 2.
    stage.

    switch_to_runmode(mission, "seco").
  } else {
    rcs off.
    unlock steering.
    wait 4.
    processor(ship_family() + "-cpu"):connection:sendmessage("detach").

    switch_to_runmode(mission, "sink").
  }
}

function _seco {
  parameter mission.

  if stage:solidfuel > 0.1 {
    return.
  }

  notify_info("seco").

  if ship_haspart("scunner-te") {
    stage.
    wait 8.
    stage.

    switch_to_runmode(mission, "teco").
  } else {
    rcs off.
    unlock steering.
    wait 4.
    processor(ship_family() + "-cpu"):connection:sendmessage("detach").

    switch_to_runmode(mission, "sink").
  }
}

function _teco {
  parameter mission.

  if stage:solidfuel > 0.1 {
    return.
  }

  notify_info("teco").

  rcs off.
  unlock steering.
  wait 4.
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
sequence:add("seco", _seco@).
sequence:add("teco", _teco@).
sequence:add("sink", _sink@).

local events is lexicon().

run_mission(sequence, events).

//
// stayputnik-cpu: staypytnik capsule.
//

include("utils/mission-runner.ks").
include("utils/capsule.ks").
include("utils/ship.ks").

local do_launch is false.

//
// Mission sequence.
//

function _launch {
  parameter mission.

  if not do_launch {
    return.
  }

  notify_info("detach").
  stage.
  wait 4.

  local str is make_capsule_suborbital_steering().
  lock steering to str().
  rcs on.

  add_event(mission, "science", _science@).

  switch_to_runmode(mission, "apogee").
}

function _apogee {
  parameter mission.

  if ship:verticalspeed >= 0 {
    return.
  }

  notify_info("apogee").
  stage.

  switch_to_runmode(mission, "chute").
}

function _chute {
  parameter mission.

  if (ship:sensors:pres * constant:kpatoatm) <= chute_pres {
    return.
  }
  notify_info("chutes on").

  rcs off.
  unlock steering.

  switch_to_runmode(mission, "sink").
}

function _sink {
  parameter mission.
}

function _messages {
  parameter mission.

  if core:messages:empty {
    return.
  }

  local msg is core:messages:pop().

  if msg:content = "detach" {
    set do_launch to true.
  }
}

function _science {
  parameter mission.

  if ship:verticalspeed >= 0 {
    return.
  }

  for science in ship_science() {
    science:deploy().
  }

  remove_event(mission, "science").
}

//
// Script entry point.
//

local chute_pres is capsule_chutes_min_pressure().

local sequence is lexicon().
sequence:add("launch", _launch@).
sequence:add("apogee", _apogee@).
sequence:add("chute", _chute@).
sequence:add("sink", _sink@).

local events is lexicon().
events:add("messages", _messages@).

run_mission(sequence, events).

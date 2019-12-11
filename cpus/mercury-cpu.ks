//
// mercury-cpu: mercury capsule.
//

include("utils/mission-runner.ks").
include("utils/capsule.ks").
include("utils/mfd.ks").
include("utils/ship.ks").

local do_detach is false.

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local science is make_first_science_mfd_page(ship_science()).

  mfd_init(science).

  switch_to_runmode(mission, "detach").
}

function _detach {
  parameter mission.

  if not do_detach {
    return.
  }

  stage.
  if ship:status = "ORBITAL" or ship:status = "SUB_ORBITAL" {
    wait 4.
  }

  local str is make_capsule_suborbital_steering().
  lock steering to str().
  rcs on.

  switch_to_runmode(mission, "apogee").
}

function _apogee {
  parameter mission.

  if ship:verticalspeed >= 0 {
    return.
  }

  stage.

  switch_to_runmode(mission, "chute").
}

function _chute {
  parameter mission.

  if (ship:sensors:pres * constant:kpatoatm) <= chute_pres {
    return.
  }

  rcs off.
  unlock steering.

  switch_to_runmode(mission, "shield").
}

function _shield {
  parameter mission.

  if ship:verticalspeed <= -10 {
    return.
  }

  drop_heatshield().

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

  local msg is core:messages:peek().

  if msg:content = "detach" {
    set do_detach to true.
    core:messages:pop().
  }
}

//
// Script entry point.
//

local chute_pres is capsule_chutes_min_pressure().

local sequence is lexicon().
sequence:add("launch", _launch@).
sequence:add("detach", _detach@).
sequence:add("apogee", _apogee@).
sequence:add("chute", _chute@).
sequence:add("shield", _shield@).
sequence:add("sink", _sink@).

local events is lexicon().
events:add("mfd", mfd_update@).
events:add("messages", _messages@).
events:add("science", make_science()).

run_mission(sequence, events).

//
// mission-runner.ks: run a mission.
//

function run_mission {
  parameter sequence.
  parameter events.

  local done is false.
  local runmode is "launch".

  function _load_runmode {
    if exists("runmode.json") {
      local json is readjson("runmode.json").
      if json:haskey("value") {
        set runmode to json["value"].
      }
    }
  }
  function _store_runmode {
    local json is lexicon("value", runmode).
    writejson(json, "runmode.json").
  }

  function _add_runmode {
    parameter runmode.
    parameter handler.
    if sequence:haskey(runmode) {
      sequence:remove(runmode).
    }
    sequence:add(runmode, handler).
  }
  function _remove_runmode {
    parameter runmode.
    if sequence:haskey(runmode) {
      sequence:remove(runmode).
    }
  }

  function _add_event {
    parameter event.
    parameter handler.
    if events:haskey(event) {
      events:remove(event).
    }
    events:add(event, handler).
  }
  function _remove_event {
    parameter event.
    if events:haskey(event) {
      events:remove(event).
    }
  }

  function _read_runmode {
    return runmode.
  }
  function _switch_to_runmode {
    parameter new_runmode.
    set runmode to new_runmode.
    _store_runmode().
  }

  function _terminate {
    set done to true.
  }

  local mission is lexicon().
  mission:add("add_runmode", _add_runmode@).
  mission:add("remove_runmode", _remove_runmode@).
  mission:add("add_event", _add_event@).
  mission:add("remove_event", _remove_event@).
  mission:add("runmode", _read_runmode@).
  mission:add("switch_to", _switch_to_runmode@).
  mission:add("terminate", _terminate@).

  _load_runmode().

  until done {
    sequence[runmode](mission).
    for event in events:values {
      event(mission).
    }
    wait 0.01.
  }
}

function add_runmode {
  parameter mission.
  parameter runmode.
  parameter handler.
  mission["add_runmode"](runmode, handler).
}

function remove_runmode {
  parameter mission.
  parameter runmode.
  mission["remove_runmode"](runmode).
}

function add_event {
  parameter mission.
  parameter event.
  parameter handler.
  mission["add_event"](event, handler).
}

function remove_event {
  parameter mission.
  parameter event.
  mission["remove_event"](event).
}

function read_runmode {
  parameter mission.
  return mission["runmode"](runmode).
}

function switch_to_runmode {
  parameter mission.
  parameter runmode.
  mission["switch_to"](runmode).
}

function terminate {
  parameter mission.
  mission["terminate"]().
}

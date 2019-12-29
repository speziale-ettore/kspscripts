//
// watchdog-cpu: watchdog cpu.
//

include("utils/mission-runner.ks").
include("utils/ship.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local i is 0.
  local j is -1.
  list processors in all_cpus.

  until i = all_cpus:length {
    if all_cpus[i]:tag = core:tag {
      set j to i.
    }
    set i to i + 1.
  }
  if j = -1 {
    wait 2.
    return.
  }
  all_cpus:remove(j).

  local pings is lexicon().
  for cpu in all_cpus {
    set pings[cpu:tag] to false.
  }

  core:messages:clear().

  for cpu in all_cpus {
    cpu:connection:sendmessage("ping-" + core:tag).
  }

  wait 2.

  if not core:messages:empty {
    for cpu in all_cpus {
      local msg is core:messages:pop().
      if msg:content:startswith("pong-") {
        set pings[msg:content:substring(5, msg:content:length - 5)] to true.
      }
    }
  }

  for tag in pings:keys {
    if not pings[tag] and ship_haspart(tag) {
      local cpu is processor(tag).

      notify_err("Restart cpu '" + tag + "'").

      cpu:deactivate().
      for path in cpu:volume:root:list:keys() {
        cpu:volume:delete(path).
      }
      download("boot/boot.ks", cpu:tag).
      cpu:activate().
    }
  }
}

//
// Script entry point.
//

local sequence is lexicon().
sequence:add("launch", _launch@).

local events is lexicon().

run_mission(sequence, events).

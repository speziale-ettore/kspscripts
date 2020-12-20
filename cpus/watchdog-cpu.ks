//
// watchdog-cpu.ks: watchdog cpu.
//

include("utils/mission-runner.ks").
include("utils/ship.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  local i is 0.
  list processors in all_cpus.
  local watch_cpus is list().

  until i = all_cpus:length {
    if all_cpus[i]:tag <> core:tag and all_cpus[i]:tag <> "terminal-cpu" {
      watch_cpus:add(all_cpus[i]).
    }
    set i to i + 1.
  }

  local pings is lexicon().
  for cpu in watch_cpus {
    set pings[cpu:tag] to false.
  }

  core:messages:clear().

  for cpu in watch_cpus {
    cpu:connection:sendmessage("ping-" + core:tag).
  }

  wait 2.

  for cpu in watch_cpus {
    if not core:messages:empty {
      local msg is core:messages:pop().
      if msg:content:istype("string") and msg:content:startswith("pong-") {
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

  wait 2.
}

//
// Script entry point.
//

local sequence is lexicon().
sequence:add("launch", _launch@).

local events is lexicon().

run_mission(sequence, events).

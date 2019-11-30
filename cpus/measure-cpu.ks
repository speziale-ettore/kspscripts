//
// measure-cpu: testbed cpu.
//

include("utils/mission-runner.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.
}

//
// Script entry point.
//

local sequence is lexicon().
sequence:add("launch", _launch@).

local events is lexicon().

run_mission(sequence, events).

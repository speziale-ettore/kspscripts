//
// measure-cpu: testbed cpu.
//

include("utils/mission-runner.ks").
include("utils/mfd.ks").
include("utils/science.ks").
include("utils/ship.ks").
include("utils/watchdog.ks").

//
// Mission sequence.
//

function _launch {
  parameter mission.

  // Science MFD.

  local science is make_first_science_mfd_page(ship_science()).

  // Planets MFD.

  local hello_venus is make_first_mfd_page(_make_hello("Venus")).
  local hello_earth is make_mfd_page(_make_hello("Earth")).
  local hello_mars is make_mfd_page(_make_hello("Mars")).

  set_next_mfd_page(hello_venus, hello_earth).
  set_next_mfd_page(hello_earth, hello_mars).
  set_next_mfd_page(hello_mars, hello_venus).

  local hello_jupiter is make_first_mfd_page(_make_hello("Jupiter")).
  local hello_saturn is make_mfd_page(_make_hello("Saturn")).
  local hello_uranus is make_mfd_page(_make_hello("Uranus")).
  local hello_neptune is make_mfd_page(_make_hello("Neptune")).

  set_next_mfd_page(hello_jupiter, hello_saturn).
  set_next_mfd_page(hello_saturn, hello_uranus).
  set_next_mfd_page(hello_uranus, hello_neptune).
  set_next_mfd_page(hello_neptune, hello_jupiter).

  local rocky_planets is make_mfd_page(_rocky_planets@).

  set_sub_mfd_page(rocky_planets, 4, hello_venus).
  set_sub_mfd_page(rocky_planets, 5, hello_earth).
  set_sub_mfd_page(rocky_planets, 6, hello_mars).

  local gas_planets is make_mfd_page(_gas_planets@).

  set_sub_mfd_page(gas_planets, 4, hello_jupiter).
  set_sub_mfd_page(gas_planets, 5, hello_saturn).
  set_sub_mfd_page(gas_planets, 6, hello_uranus).
  set_sub_mfd_page(gas_planets, 7, hello_neptune).

  // MFD initialization.

  set_next_mfd_page(science, rocky_planets).
  set_next_mfd_page(rocky_planets, gas_planets).
  set_next_mfd_page(gas_planets, science).

  mfd_init(science).

  switch_to_runmode(mission, "loop").
}

function _loop {
  parameter mission.
}

function _rocky_planets {
  parameter update.
  if not update {
    print "Rocky Planets:".
    print "  4. Venus".
    print "  5. Earth".
    print "  6. Mars".
  }
}

function _gas_planets {
  parameter update.
  if not update {
    print "Gas Planets:".
    print "  4. Jupiter".
    print "  5. Saturn".
    print "  6. Uranus".
    print "  7. Neptune".
  }
}

function _make_hello {
  parameter planet.

  function _hello {
    parameter update.
    if not update {
      print "Hello, " + planet + "!".
    }
  }

  return _hello@.
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
events:add("watchdog", soft_reset@).

run_mission(sequence, events).

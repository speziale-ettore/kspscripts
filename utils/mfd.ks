//
// mfd: multi functional display.
//

include("math/modulo.ks").
include("plane/flap.ks").
include("utils/science.ks").

//
// mfd pages implementation.
//

function _default_render {
  parameter update.

  if not update {
    print "Welcome to the MFD world!".
  }
}

function make_mfd_page {
  parameter render is _default_render@.
  parameter first is false.

  local page is lexicon().
  set page["render"] to render.
  set page["next"] to page.
  set page["first"] to first.

  return page.
}

function make_first_mfd_page {
  parameter render is _default_render@.

  return make_mfd_page(render, true).
}

function set_next_mfd_page {
  parameter a_page.
  parameter b_page.

  set a_page["next"] to b_page.
  set b_page["prev"] to a_page.
}

function set_mfd_action {
  parameter a_page.
  parameter ag.
  parameter act.

  set a_page["ag" + ag] to act.
}

function set_sub_mfd_page {
  parameter a_page.
  parameter ag.
  parameter b_page.

  set b_page["parent"] to a_page.

  function _sub_page {
    local first_page is b_page.
    until first_page["first"] {
      set first_page to first_page["next"].
    }

    set cur_page to b_page.

    local page is first_page.

    set cur_page_no to 0.
    until page = cur_page {
      set cur_page_no to cur_page_no + 1.
      set page to page["next"].
    }

    set cur_num_pages to cur_page_no + 1.
    until page["next"] = first_page {
      set cur_num_pages to cur_num_pages + 1.
      set page to page["next"].
    }
  }

  set_mfd_action(a_page, ag, _sub_page@).
}

//
// mfd implementation.
//

local cur_page is make_mfd_page().
local cur_page_no is 0.
local cur_num_pages is 1.

local draw_all is 0.
local draw_update is 1.
local draw_mode is draw_all.

on ag1 {
  set cur_page to cur_page["prev"].
  set cur_page_no to modulo(cur_page_no - 1, cur_num_pages).
  set draw_mode to draw_all.
  preserve.
}

on ag2 {
  if cur_page:haskey("parent") {
    local first_page is cur_page["parent"].
    until first_page["first"] {
      set first_page to first_page["next"].
    }

    set cur_page to cur_page["parent"].

    local page is first_page.

    set cur_page_no to 0.
    until page = cur_page {
      set cur_page_no to cur_page_no + 1.
      set page to page["next"].
    }

    set cur_num_pages to cur_page_no + 1.
    until page["next"] = first_page {
      set cur_num_pages to cur_num_pages + 1.
      set page to page["next"].
    }
  }
  set draw_mode to draw_all.
  preserve.
}

on ag3 {
  set cur_page to cur_page["next"].
  set cur_page_no to modulo(cur_page_no + 1, cur_num_pages).
  set draw_mode to draw_all.
  preserve.
}

on ag4 {
  if cur_page:haskey("ag" + 4) {
    cur_page["ag4"]().
  }
  set draw_mode to draw_all.
  preserve.
}

on ag5 {
  if cur_page:haskey("ag" + 5) {
    cur_page["ag5"]().
  }
  set draw_mode to draw_all.
  preserve.
}

on ag6 {
  if cur_page:haskey("ag" + 6) {
    cur_page["ag6"]().
  }
  set draw_mode to draw_all.
  preserve.
}

on ag7 {
  if cur_page:haskey("ag" + 7) {
    cur_page["ag7"]().
  }
  set draw_mode to draw_all.
  preserve.
}

on ag8 {
  if cur_page:haskey("ag" + 8) {
    cur_page["ag8"]().
  }
  set draw_mode to draw_all.
  preserve.
}

on ag9 {
  if cur_page:haskey("ag" + 9) {
    cur_page["ag9"]().
  }
  set draw_mode to draw_all.
  preserve.
}

on ag10 {
  if cur_page:haskey("ag" + 10) {
    cur_page["ag10"]().
  }
  set draw_mode to draw_all.
  preserve.
}

function mfd_init {
  parameter page is make_mfd_page().

  set cur_page to page.
  set cur_page_no to 0.

  set cur_num_pages to 1.
  until page["next"] = cur_page {
    set cur_num_pages to cur_num_pages + 1.
    set page to page["next"].
  }
}

function mfd_update {
  parameter mission.

  local mode is draw_mode.

  if mode = draw_all {
    clearscreen.
    print "Page ".
  }

  print_line((cur_page_no + 1) + "/" + cur_num_pages, 6, 0).

  if mode = draw_all {
    print " ".
  }

  cur_page["render"](mode).

  if mode = draw_all {
    set draw_mode to draw_update.
  }
}

function print_line {
  parameter msg.
  parameter col is 0.
  parameter row is 0.
  parameter err_msg is "".

  if col + msg:length > terminal:width {
    set msg to err_msg.
  }
  until col + msg:length = terminal:width {
    set msg to msg + " ".
  }
  print msg at (col, row).
}

//
// Engineering mfd.
//

function make_engineering_mfd_page {
  parameter engines is list().
  parameter flaps is list().
  parameter first is false.

  local main_cpu is processor(ship_family() + "-cpu").

  function _render {
    parameter update.

    if not update {
      for engine in engines {
        print "Engine: " + engine:title.
        print "  Fuel Flow: ".
        print "  Thrust: ".
      }
      print " ".
      if not flaps:empty {
        for flap in flaps {
          print "Flap: " + flap:part:title.
          print "  Angle: ".
        }
        print " ".
      }
      print "Actions:".
      print "  4. Toggle Engines".
      if not flaps:empty {
        print "  5. Toggle Auto Flaps".
        print "  6. Less Flaps".
        print "  7. More Flaps".
      }
    }

    local row_no is 3.

    for engine in engines {
      print_line(round(engine:fuelflow, 6) + " Kg/s", 13, row_no).
      set row_no to row_no + 1.
      print_line(round(engine:thrust, 1) + " kN", 10, row_no).
      set row_no to row_no + 2.
    }
    if not flaps:empty {
      set row_no to row_no + 1.
      for flap in flaps {
        print_line(round(flap_get_angle(flap), 1) + " deg", 9, row_no).
        set row_no to row_no + 2.
      }
    }
  }

  local page is make_mfd_page(_render@, first).

  function _toggle_engines {
    for engine in engines {
      if not engine:ignition {
        engine:activate().
      } else {
        engine:shutdown().
      }
    }
  }

  function _toggle_auto_flaps {
    main_cpu:connection:sendmessage("toggle_auto_flaps").
  }

  function _less_flaps {
    main_cpu:connection:sendmessage("less_flaps").
  }

  function _more_flaps {
    main_cpu:connection:sendmessage("more_flaps").
  }

  set_mfd_action(page, 4, _toggle_engines@).
  set_mfd_action(page, 5, _toggle_auto_flaps@).
  set_mfd_action(page, 6, _less_flaps@).
  set_mfd_action(page, 7, _more_flaps@).

  return page.
}

function make_first_engineering_mfd_page {
  parameter engines is list().
  parameter flaps is list().

  return make_engineering_mfd_page(engines, flaps, true).
}

//
// Autopilot mfd.
//

function make_autoheading_mfd_page {
  parameter first is false.

  function _render {
    parameter update.

    if not update {
      print "Autopilot: Heading".
      print "  Heading: ".
      print "  Speed: ".
      print "  Altitude: ".
      print "  Engaged: ".
      print " ".
      print "Actions:".
      print "  4. Less Heading".
      print "  5. More Heading".
      print "  6. Less Speed".
      print "  7. More Speed".
      print "  8. Less Altitude".
      print "  9. More Altitude".
      print "  0. Toggle Autopilot".
    }
  }

  local page is make_mfd_page(_render@, first).

  function _less_heading {
  }
  function _more_heading {
  }

  function _less_speed {
  }
  function _more_speed {
  }

  function _less_altitude {
  }
  function _more_altitude {
  }

  function _toggle_autopilot {
  }

  set_mfd_action(page, 4, _less_heading@).
  set_mfd_action(page, 5, _more_heading@).
  set_mfd_action(page, 6, _less_speed@).
  set_mfd_action(page, 7, _more_speed@).
  set_mfd_action(page, 8, _less_altitude@).
  set_mfd_action(page, 9, _more_altitude@).
  set_mfd_action(page, 10, _toggle_autopilot@).

  return page.
}

function make_first_autoheading_mfd_page {
  return make_autoheading_mfd_page(true).
}

function make_autoloitering_mfd_page {
  parameter first is false.

  function _render {
    parameter update.

    if not update {
      print "Autopilot: Loitering".
      print "  Turn Rate: ".
      print "  Speed: ".
      print "  Altitude: ".
      print "  Engaged: ".
      print " ".
      print "Actions:".
      print "  4. Less Turn Rate: ".
      print "  5. More Turn Rate: ".
      print "  6. Less Speed".
      print "  7. More Speed".
      print "  8. Less Altitude".
      print "  9. More Altitude".
      print "  0. Toggle Autopilot".
    }
  }

  local page is make_mfd_page(_render@, first).

  function _less_turn_rate {
  }
  function _more_turn_rate {
  }

  function _less_speed {
  }
  function _more_speed {
  }

  function _less_altitude {
  }
  function _more_altitude {
  }

  function _toggle_autopilot {
  }

  set_mfd_action(page, 4, _less_turn_rate@).
  set_mfd_action(page, 5, _more_turn_rate@).
  set_mfd_action(page, 6, _less_speed@).
  set_mfd_action(page, 7, _more_speed@).
  set_mfd_action(page, 8, _less_altitude@).
  set_mfd_action(page, 9, _more_altitude@).
  set_mfd_action(page, 10, _toggle_autopilot@).

  return page.
}

function make_first_autoloitering_mfd_page {
  return make_loitering_mfd_page(true).
}

function make_autopilot_mfd_page {
  parameter first is false.

  function _render {
    parameter update.

    if not update {
      print "Autopilots:".
      print "  4. Heading".
      print "  5. Loitering".
    }
  }

  local page is make_mfd_page(_render@, first).

  local heading is make_first_autoheading_mfd_page().
  local loitering is make_autoloitering_mfd_page().

  set_next_mfd_page(heading, loitering).
  set_next_mfd_page(loitering, heading).

  set_sub_mfd_page(page, 4, heading).
  set_sub_mfd_page(page, 5, loitering).

  return page.
}

function make_first_autopilot_mfd_page {
  return make_autopilot_mfd_page(true).
}

//
// Navigation mfd.
//

function make_hud_airstrip {
  parameter waypoint.

  local start is waypoint(waypoint:name + " Start").
  local end is waypoint(waypoint:name + " End").

  function _start {
    return start:position.
  }
  function _end {
    return end:position.
  }
  function _y {
    return vcrs(end:position - start:position,
                body:position - start:position):normalized.
  }
  function _z {
    return (start:position - body:position):normalized.
  }

  local hud is list().

  for d in list(-10, 10) {
    local cur_d is d.
    local vec is vecdraw({ return _start() + cur_d * _y(). },
                         { return _end() - _start() + cur_d * _y(). },
                         rgb(1, 0, 0), "", 1.0, false, 1.5, false).
    hud:add(vec).
  }

  return hud.
}

function make_hud_target {
  parameter waypoint.
  local vec is vecdraw(v(0, 0, 0), { return waypoint:position. }, rgb(1, 1, 0)).
  return list(vec).
}

function hud_show {
  parameter hud.
  parameter new_show.

  local old_show is hud[0]:show.
  for vec in hud {
    set vec:show to new_show.
  }

  return old_show.
}

function hud_flip {
  parameter hud.

  for vec in hud {
    set vec:show to not vec:show.
  }
}

function make_navigation_mfd_page {
  parameter waypoints is list().
  parameter first is false.

  local cur_waypoint_no is 0.
  local huds is list().

  for waypoint in waypoints {
    if waypoint:name = "KSC" {
      huds:add(make_hud_airstrip(waypoint)).
    } else {
      huds:add(make_hud_target(waypoint)).
    }
  }

  function _render {
    parameter update.

    if not update {
      print "Waypoint Name: ".
      print "Waypoint Distance: ".
      print " ".
      print "Actions:".
      print "  4. Prev Waypoint".
      print "  5. Next Waypoint".
      print "  6. Toggle HUD".
      print "  7. Toggle Reference".
    }

    print_line(waypoints[cur_waypoint_no]:name, 15, 2).
    print_line(round(waypoints[cur_waypoint_no]:position:mag / 1000, 1) + " Km",
                     19, 3, "inf Km").
  }

  local page is make_mfd_page(_render@, first).

  function _prev_waypoint {
    local show is hud_show(huds[cur_waypoint_no], false).
    set cur_waypoint_no to modulo(cur_waypoint_no - 1, waypoints:length).
    hud_show(huds[cur_waypoint_no], show).
  }

  function _next_waypoint {
    local show is hud_show(huds[cur_waypoint_no], false).
    set cur_waypoint_no to modulo(cur_waypoint_no + 1, waypoints:length).
    hud_show(huds[cur_waypoint_no], show).
  }

  function _toggle_hud {
    hud_flip(huds[cur_waypoint_no]).
  }

  local ax is vecdraw(v(0, 0, 0), 10 * ship:facing:forevector:normalized,
                      rgb(1, 0, 0), "x").
  local ay is vecdraw(v(0, 0, 0), 10 * ship:facing:topvector:normalized,
                      rgb(0, 1, 0), "y").
  local az is vecdraw(v(0, 0, 0), 10 * ship:facing:starvector:normalized,
                     rgb(0, 0, 1), "z").

  function _toggle_reference {
    set ax:show to not ax:show.
    set ay:show to not ay:show.
    set az:show to not az:show.
  }

  set_mfd_action(page, 4, _prev_waypoint@).
  set_mfd_action(page, 5, _next_waypoint@).
  set_mfd_action(page, 6, _toggle_hud@).
  set_mfd_action(page, 7, _toggle_reference@).

  return page.
}

function make_first_navigation_mfd_page {
  parameter waypoints is list().

  return make_navigation_mfd_page(waypoints, true).
}

//
// Science mfd.
//

function make_science_mfd_page {
  parameter science is list().
  parameter first is false.

  local science_cpu is false.
  if ship_haspart(ship_family() + "-science-cpu") {
    set scince_cpu to processor(ship_family() + "-science-cpu").
  } else if ship_haspart("science-cpu") {
    set science_cpu to processor("science-cpu").
  } else {
    set science_cpu to core.
  }

  function _render {
    parameter update.

    if not update {
      print "Experiments:".
      for experiment in science {
        print "  *. " + experiment:part:title + " -> ".
      }
      print " ".
      print "Actions:".
      print "  4. Run All".
      print "  5. Transmit All".
      print "  6. Reset All".
    }

    local row_no is 3.

    for experiment in science {
      local col_no is 5 + experiment:part:title:length + 4.
      print_line(round(science_data(experiment), 1) + " Mits, " +
                 round(science_transmit(experiment), 1) + "/" +
                 round(science_recovery(experiment), 1) + " Science",
                 col_no, row_no).
      set row_no to row_no + 1.
    }
  }

  local page is make_mfd_page(_render@, first).

  function _run_all {
    science_cpu:connection:sendmessage("run_all_experiments").
  }

  function _transmit_all {
    science_cpu:connection:sendmessage("transmit_all_experiments").
  }

  function _reset_all {
    science_cpu:connection:sendmessage("reset_all_experiments").
  }

  set_mfd_action(page, 4, _run_all@).
  set_mfd_action(page, 5, _transmit_all@).
  set_mfd_action(page, 6, _reset_all@).

  return page.
}

function make_first_science_mfd_page {
  parameter science is list().

  return make_science_mfd_page(science, true).
}

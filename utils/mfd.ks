//
// mfd: multi functional display.
//

include("math/modulo.ks").
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
// Navigation mfd.
//

function make_navigation_mfd_page {
  parameter waypoints is list().
  parameter first is false.

  local cur_waypoint_no is 0.

  local hud_vectors is list().
  for waypoint in waypoints {
    local cur_waypoint is waypoint.
    hud_vectors:add(vecdraw(v(0, 0, 0), { return cur_waypoint:position. },
                    rgb(1, 1, 0))).
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
    local show is hud_vectors[cur_waypoint_no]:show.
    set hud_vectors[cur_waypoint_no]:show to false.
    set cur_waypoint_no to modulo(cur_waypoint_no - 1, waypoints:length).
    set hud_vectors[cur_waypoint_no]:show to show.
  }

  function _next_waypoint {
    local show is hud_vectors[cur_waypoint_no]:show.
    set hud_vectors[cur_waypoint_no]:show to false.
    set cur_waypoint_no to modulo(cur_waypoint_no + 1, waypoints:length).
    set hud_vectors[cur_waypoint_no]:show to show.
  }

  function _toggle_hud {
    set hud_vectors[cur_waypoint_no]:show to
        not hud_vectors[cur_waypoint_no]:show.
  }

  local ax is vecdraw(v(0, 0, 0), v(10, 0, 0), rgb(1, 0, 0), "x").
  local ay is vecdraw(v(0, 0, 0), v(0, 10, 0), rgb(0, 1, 0), "y").
  local az is vecdraw(v(0, 0, 0), v(0, 0, 10), rgb(0, 0, 1), "z").

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
      print_line(science_data(experiment) + " Mits, " +
                 science_transmit(experiment) + "/" +
                 science_recovery(experiment) + " Science", col_no, row_no).
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

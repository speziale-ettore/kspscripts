//
// navigation-mfd.ks: navigation mfd.
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

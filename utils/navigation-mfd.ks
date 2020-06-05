//
// navigation-mfd.ks: navigation mfd.
//

include("utils/navigation.ks").

function make_navigation_mfd_page {
  parameter courses is list().
  parameter first is false.

  local auto_cpu is false.
  if ship_haspart(ship_family() + "-auto-cpu") {
    set auto_cpu to processor(ship_family() + "-auto-cpu").
  } else if ship_haspart("auto-cpu") {
    set auto_cpu to processor("auto-cpu").
  } else {
    set auto_cpu to processor(ship_family() + "-cpu").
  }

  local hud_cpu is false.
  if ship_haspart(ship_family() + "-hud-cpu") {
    set hud_cpu to processor(ship_family() + "-hud-cpu").
  } else if ship_haspart("hud-cpu") {
    set hud_cpu to processor("hud-cpu").
  } else {
    set hud_cpu to processor(ship_family() + "-cpu").
  }

  local cur_course_no is 0.
  local followed_course_no is -1.

  local auto_disabled is 0.
  local auto_director is 1.
  local auto_pilot is 2.
  local auto_mode is auto_disabled.

  local cur_waypoint is false.

  function _render {
    parameter update.

    if not update {
      print "Course Name: ".
      print "Course Length: ".
      print "Course Distance: ".
      print " ".
      print "Engaged Course: ".
      print "  Name: ".
      print "  Next Waypoint Distance: ".
      print "  Next Waypoint ETA: ".
      print "  Autopilot: ".
      print " ".
      print "Actions:".
      print "  4. Prev Course".
      print "  5. Next Course".
      print "  6. ".
      print "  7. ".
      print "  8. Toggle HUD".
      print "  9. Toggle Reference".
    }

    if courses:empty {
      print_line("N/A", 13, 2).
      print_line("N/A", 15, 3).
      print_line("N/A", 17, 4).

    } else {
      print_line(course_get_name(courses[cur_course_no]), 13, 2).

      local course_length is course_get_length(courses[cur_course_no]).
      if course_length = 0 {
        print_line("N/A", 15, 3).
      } else {
        print_line(round( course_length / 1000, 1) + " Km", 15, 3, "inf Km").
      }

      print_line(round(course_get_distance(courses[cur_course_no]) / 1000, 1)
                 + " Km", 17, 4, "inf Km").
    }

    if not core:messages:empty {
      local msg is core:messages:peek().

      if msg:content:istype("lexicon") and msg:content:haskey("auto_mode") {
        if msg:content["auto_mode"] = "disabled" {
          set followed_course_no to -1.
          set auto_mode to auto_disabled.
          set cur_waypoint to false.
        } else if msg:content["auto_mode"] = "director" {
          set followed_course_no to msg:content["cur_course"].
          set auto_mode to auto_director.
          if msg:content:haskey("cur_waypoint") {
            set cur_waypoint to msg:content["cur_waypoint"].
          } else {
            set cur_waypoint to false.
          }
        } else if msg:content["auto_mode"] = "pilot" {
          set followed_course_no to msg:content["cur_course"].
          set auto_mode to auto_pilot.
          if msg:content:haskey("cur_waypoint") {
            set cur_waypoint to msg:content["cur_waypoint"].
          } else {
            set cur_waypoint to false.
          }
        }
        core:messages:pop().
      }
    }

    if auto_mode = auto_disabled or followed_course_no = -1 {
      print_line("N/A", 8, 7).
      print_line("N/A", 26, 8).
      print_line("N/A", 21, 9).
      print_line("N/A", 13, 10).
    } else {
      print_line(course_get_name(courses[followed_course_no]), 8, 7).
      if cur_waypoint:istype("lexicon") {
        local way_dist is waypoint_get_distance(cur_waypoint).
        local way_eta is waypoint_get_eta(cur_waypoint).
        print_line(round(way_dist / 1000, 1) + " Km", 26, 8, "inf Km").
        if way_eta = -1 {
          print_line("inf h", 21, 9).
        } else {
          print_line(round(way_eta / 3600, 1) + " h", 21, 9, "inf h").
        }
      } else {
        print_line("N/A", 26, 8).
        print_line("N/A", 21, 9).
      }
      if auto_mode = auto_director {
        print_line("Director", 13, 10).
      } else if auto_mode = auto_pilot {
        print_line("Yes").
      }
    }

    if auto_mode = auto_disabled or followed_course_no = -1 {
      print_line("Engage Course", 5, 15).
      print_line("Navigate Course", 5, 16).
    } else if auto_mode = auto_director {
      print_line("Disengage Course", 5, 15).
      print_line("Navigate Course", 5, 16).
    } else if auto_mode = auto_pilot {
      print_line("Engage Course").
      print_line("Abandon Course").
    }
  }

  local page is make_mfd_page(_render@, first).

  function _prev_course {
    if not courses:empty {
      set cur_course_no to modulo(cur_course_no - 1, courses:length).
    }
  }

  function _next_course {
    if not courses:empty {
      set cur_course_no to modulo(cur_course_no + 1, courses:length).
    }
  }

  function _toggle_engage_course {
    if not courses:empty {
      auto_cpu:connection:sendmessage(
        lexicon("toggle_engage_course", cur_course_no)).
    }
  }

  function _toggle_navigate_course {
    if not courses:empty {
      auto_cpu:connection:sendmessage(
        lexicon("toggle_navigate_course", cur_course_no)).
    }
  }

  function _toggle_hud {
    hud_cpu:connection:sendmessage("toggle_hud").
  }

  function _toggle_reference {
    hud_cpu:connection:sendmessage("toggle_reference").
  }

  set_mfd_action(page, 4, _prev_course@).
  set_mfd_action(page, 5, _next_course@).
  set_mfd_action(page, 6, _toggle_engage_course@).
  set_mfd_action(page, 7, _toggle_navigate_course@).
  set_mfd_action(page, 8, _toggle_hud@).
  set_mfd_action(page, 9, _toggle_reference@).

  return page.
}

function make_first_navigation_mfd_page {
  parameter courses is list().

  return make_navigation_mfd_page(courses, true).
}

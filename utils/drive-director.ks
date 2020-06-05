//
// drive-director.ks: give indication to the driver.
//

include("utils/ship.ks").
include("utils/navigation.ks").

local mfd_cpu is false.
local hud_cpu is false.

local all_courses is false.
local cur_course_no is -1.
local cur_waypoint_no is -1.
local cur_heading is -1.

function drive_director_init {
  parameter courses.

  set mfd_cpu to ship_mfd_cpu().
  set hud_cpu to ship_hud_cpu().

  set all_courses to courses.
}

function drive_director_update {
  parameter mission.

  // Handle all incoming commands.

  if not core:messages:empty {
    local msg is core:messages:peek().

    if msg:content:istype("lexicon") {
      if msg:content:haskey("toggle_engage_course") {
        if cur_course_no < 0 {
          set cur_course_no to msg:content["toggle_engage_course"].
        } else {
          set cur_course_no to -1.
        }
        core:messages:pop().

      } else if msg:content:haskey("toggle_navigate_course") {
        core:messages:pop().
      }
    }
  }

  // Compute drive directions.

  local cur_waypoints is list().
  local cur_waypoint is false.

  if cur_course_no >= 0 {
    set cur_waypoints to course_get_waypoints(all_courses[cur_course_no]).
    if cur_waypoint_no = -1 {
      set cur_waypoint_no to 0.
    }
    until cur_waypoint_no >= cur_waypoints:length or
          not waypoint_reached(cur_waypoints[cur_waypoint_no]) {
      set cur_waypoint_no to cur_waypoint_no + 1.
    }
    if cur_waypoint_no = cur_waypoints:length {
      set cur_course_no to -1.
    } else {
      set cur_waypoint to cur_waypoints[cur_waypoint_no].
      set cur_heading to waypoint_get_heading(cur_waypoint).
    }
  }

  // Multicast drive director status.

  local status is lexicon().

  if cur_course_no = -1 {
    set status["auto_mode"] to "disabled".
    set status["cur_course"] to -1.

  } else {
    set status["auto_mode"] to "director".
    set status["cur_course"] to cur_course_no.
    set status["cur_waypoint"] to cur_waypoint.
    set status["cur_heading"] to cur_heading.
    set status["cur_pitch"] to 0.
  }

  for cpu in list(mfd_cpu, hud_cpu) {
    cpu:connection:sendmessage(status).
  }
}

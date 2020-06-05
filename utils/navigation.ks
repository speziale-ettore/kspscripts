//
// navigation.ks: headings, directions, ...
//

function dir_heading {
  parameter dir.

  local trig_x is vdot(ship:north:forevector, dir:forevector).
  local trig_y is vdot(vcrs(ship:up:forevector, ship:north:forevector),
                       dir:forevector).

  local heading is arctan2(trig_y, trig_x).
  if heading < 0 {
    set heading to heading + 360.
  }

  return heading.
}

function make_waypoint {
  parameter name.
  parameter body.
  parameter geoposition.
  parameter altitude.
  parameter radius.

  return lexicon("name", name,
                 "body", body,
                 "geoposition", geoposition,
                 "altitude", altitude,
                 "radius", radius).
}

function waypoint_get_distance {
  parameter waypoint.
  return waypoint["geoposition"]:altitudeposition(waypoint["altitude"]):mag.
}

function waypoint_get_eta {
  parameter waypoint.

  if ship:velocity:surface:mag < 0.1 {
    return -1.
  }

  return waypoint["geoposition"]:altitudeposition(waypoint["altitude"]):mag /
         ship:velocity:surface:mag.
}

function waypoint_get_heading {
  parameter waypoint.
  return waypoint["geoposition"]:heading.
}

function waypoint_reached {
  parameter waypoint.
  return waypoint_get_distance(waypoint) <= waypoint["radius"].
}

function make_course_from_waypoint {
  parameter waypoint.
  parameter radius.

  return lexicon("name", waypoint:name,
                 "waypoints", list(make_waypoint(waypoint:name,
                                                 waypoint:body,
                                                 waypoint:geoposition,
                                                 waypoint:altitude,
                                                 radius)),
                 "length", 0).
}

function course_get_name {
  parameter course.
  return course["name"].
}

function course_get_waypoints {
  parameter course.
  return course["waypoints"].
}

function course_get_length {
  parameter course.
  return course["length"].
}

function course_get_distance {
  parameter course.

  local d is 0.

  for waypoint in course["waypoints"] {
    set d to d +
             waypoint["geoposition"]:altitudeposition(waypoint["altitude"]):mag.
  }

  return d.
}

local hidden_ground_waypoints is lexicon().
for name in list("KSC", "KSC Start", "KSC End") {
  set hidden_ground_waypoints[name] to true.
}
for name in list("Dessert Airfield", "Island Airfield") {
  set hidden_ground_waypoints[name] to true.
}
for name in list("Dessert Launch Site", "Woomerang Launch Site") {
  set hidden_ground_waypoints[name] to true.
}

local ground_test_tracks is lexicon().
for name in list("KSC Drive Test Track") {
  set ground_test_tracks[name] to true.
}

function all_ground_courses {
  parameter b is ship:body.

  local waypoints is list().

  for waypoint in allwaypoints() {
    if waypoint:body = b and waypoint:grounded and
       not hidden_ground_waypoints:haskey(waypoint:name) {
      waypoints:add(make_course_from_waypoint(waypoint, 1)).
    } else if ground_test_tracks:haskey(waypoint:name) {
      waypoints:add(make_course_from_waypoint(waypoint, 1)).
    }
  }

  return waypoints.
}

function all_air_courses {
  parameter b is ship:body.

  local waypoints is list().

  for waypoint in allwaypoints() {
  }

  return waypoints.
}

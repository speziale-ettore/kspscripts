//
// navigation.ks: headings, directions, ...
//

function dir_heading {
  parameter dir.

  local trig_x is vdot(ship:north:forevector, dir:forevector).
  local trig_y is vdot(vcrs(ship:up:vector, ship:north:forevector),
                       dir:forevector).

  local heading is arctan2(trig_y, trig_x).
  if heading < 0 {
    set heading to heading + 360.
  }

  return heading.
}

//
// compass.ks: navball compass.
//

function compass_heading {
  local trig_x is vdot(ship:north:forevector, ship:facing:forevector).
  local trig_y is vdot(vcrs(ship:up:forevector, ship:north:forevector),
                       ship:facing:forevector).

  local heading is arctan2(trig_y, trig_x).
  if heading < 0 {
    set heading to 360 + heading.
  }

  return heading.
}

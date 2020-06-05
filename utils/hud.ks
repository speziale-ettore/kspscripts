//
// hud.ks: head up display.
//

include("math/clamp.ks").
include("utils/compass.ks").
include("utils/ship.ks").

local hud_0d is 0.
local hud_1d is 1.
local hud_2d is 2.

local hud_kind is hud_0d.

// Lateral bars.

local l is false.
local r is false.

// Vertical bars.

local u is false.
local d is false.

// Navigation bars.

local v is false.
local h is false.

// Reference axis.

local ax is false.
local ay is false.
local az is false.

local disabled_heading is 720.
local disabled_pitch is 180.

local want_heading is disabled_heading.
local want_pitch is disabled_pitch.

function hud_init_1d {
  parameter depth.
  parameter height.
  parameter width.

  clearvecdraws().

  // Head up display.

  set hud_kind to hud_1d.

  set l to vecdraw({ return depth * ship_x() - width / 2 * ship_z(). },
                   { return height * ship_y(). },
                   rgb(0, 0, 1)).
  set l:width to 0.1.
  set l:pointy to false.

  set r to vecdraw({ return depth * ship_x() + width / 2 * ship_z(). },
                   { return height * ship_y().},
                   rgb(0, 0, 1)).
  set r:width to 0.1.
  set r:pointy to false.

  function v_err {
    if want_heading = disabled_heading {
      return 0.
    }
    return height * clamp(want_heading - compass_heading(), -90, 90) / 90.
  }
  function v_color {
    if want_heading = disabled_heading {
      return rgb(1, 0, 0).
    }
    return rgb(0, 1, 0).
  }

  set v to vecdraw({ return depth * ship_x()
                            - 0.1 * height * ship_y() +
                            v_err() * ship_z(). },
                   { return 1.2 * height * ship_y(). },
                   { return v_color(). }).
  set v:width to 0.1.
  set v:pointy to false.

  // Reference axis.

  set ax to vecdraw(v(0, 0, 0), { return 10 * ship_x(). }, rgb(1, 0, 0), "x").
  set ay to vecdraw(v(0, 0, 0), { return 10 * ship_y(). }, rgb(0, 1, 0), "y").
  set az to vecdraw(v(0, 0, 0), { return 10 * ship_z(). }, rgb(0, 0, 1), "z").
}

function hud_init_2d {
  parameter depth.
  parameter lheight.
  parameter ldisp.
  parameter vlength.
  parameter vdisp.
  parameter width.

  clearvecdraws().

  // Head up display.

  set hud_kind to hud_2d.

  set l to vecdraw({ return depth * ship_x() +
                            ldisp * ship_y() -
                            width / 2 * ship_z(). },
                   { return lheight * ship_y(). },
                   rgb(0, 0, 1)).
  set l:width to 0.1.
  set l:pointy to false.

  set r to vecdraw({ return depth * ship_x() +
                            ldisp * ship_y() +
                            width / 2 * ship_z(). },
                   { return lheight * ship_y().},
                   rgb(0, 0, 1)).
  set r:width to 0.1.
  set r:pointy to false.

  function v_err {
    if want_heading = disabled_heading {
      return 0.
    }
    return lheight * clamp(want_heading - compass_heading(), -90, 90) / 90.
  }
  function v_color {
    if want_heading = disabled_heading {
      return rgb(1, 0, 0).
    }
    return rgb(0, 1, 0).
  }

  set v to vecdraw({ return depth * ship_x() -
                            0.1 * lheight * ship_y() + ldisp * ship_y() +
                            v_err() * ship_z(). },
                   { return 1.2 * lheight * ship_y(). },
                   { return v_color(). }).
  set v:width to 0.1.
  set v:pointy to false.

  set u to vecdraw({ return depth * ship_x() +
                            width / 2 * ship_y() + vdisp * ship_y() -
                            vlength / 2 * ship_z(). },
                   { return vlength * ship_z(). },
                   rgb(0, 0, 1)).
  set u:width to 0.1.
  set u:pointy to false.

  set d to vecdraw({ return depth * ship_x() -
                            width / 2 * ship_y() + vdisp * ship_y() -
                            vlength / 2 * ship_z(). },
                   { return vlength * ship_z(). },
                   rgb(0, 0, 1)).
  set d:width to 0.1.
  set d:pointy to false.

  function h_err {
    if want_pitch = disabled_pitch {
      return 0.
    }
    return vlength * clamp(want_pitch - ship_pitch(), -40, 40) / 40.
  }
  function h_color {
    if want_pitch = disabled_pitch {
      return rgb(1, 0, 0).
    }
    return rgb(0, 1, 0).
  }

  set h to vecdraw({ return depth * ship_x() +
                            h_err * ship_y() + vdisp * ship_y() -
                            1.1 * vlength / 2 * ship_z(). },
                   { return 1.1 * vlength * ship_z(). },
                   { return h_color(). }).
  set h:width to 0.1.
  set h:pointy to false.

  // Reference axis.

  set ax to vecdraw(v(0, 0, 0), { return 10 * ship_x(). }, rgb(1, 0, 0), "x").
  set ay to vecdraw(v(0, 0, 0), { return 10 * ship_y(). }, rgb(0, 1, 0), "y").
  set az to vecdraw(v(0, 0, 0), { return 10 * ship_z(). }, rgb(0, 0, 1), "z").
}

function hud_update {
  parameter mission.

  if core:messages:empty {
    return.
  }

  local msg is core:messages:peek().

  if msg:content:istype("lexicon") and msg:content:haskey("auto_mode") {
    if msg:content["auto_mode"] = "disabled" {
      set want_heading to disabled_heading.
      set want_pitch to disabled_pitch.
    } else {
      set want_heading to msg:content["cur_heading"].
      set want_pitch to msg:content["cur_pitch"].
    }
    core:messages:pop().

  } else if msg:content:istype("string") and msg:content = "toggle_hud" {
    if hud_kind = hud_1d {
      set l:show to not l:show.
      set r:show to not r:show.
      set v:show to not v:show.
    } else if hud_kind = hud_2d {
      set l:show to not l:show.
      set r:show to not r:show.
      set v:show to not v:show.
      set u:show to not u:show.
      set d:show to not d:show.
      set h:show to not h:show.
    }
    core:messages:pop().

  } else if msg:content:istype("string") and msg:content = "toggle_reference" {
    set ax:show to not ax:show.
    set ay:show to not ay:show.
    set az:show to not az:show.
    core:messages:pop().
  }
}

//
// mfd: multi functional display.
//

include("math/modulo.ks").

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

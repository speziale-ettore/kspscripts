//
// autopilot-mfd.ks: autopilot mfd.
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

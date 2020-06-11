//
// engineering_mfd.ks: mfd engineering pages.
//

include("plane/flap.ks").

function make_engineering_mfd_page {
  parameter engines is list().
  parameter flaps is list().
  parameter first is false.

  local main_cpu is processor(ship_family() + "-cpu").

  function _render {
    parameter update.

    if not update {
      for engine in engines {
        print "Engine: " + engine:title.
        print "  Fuel Flow: ".
        print "  Thrust: ".
      }
      print " ".
      if not flaps:empty {
        for flap in flaps {
          print "Flap: " + flap:part:title.
          print "  Angle: ".
        }
        print " ".
      }
      print "Ship Pitch: ".
      print "Ship Yaw: ".
      print "Ship Roll: ".
      print "Angle of Attack: ".
      print " ".
      print "Actions:".
      print "  4. Toggle Engines".
      if not flaps:empty {
        print "  5. Toggle Auto Flaps".
        print "  6. Less Flaps".
        print "  7. More Flaps".
      }
    }

    local row_no is 3.

    for engine in engines {
      print_line(round(engine:fuelflow, 6) + " Kg/s", 13, row_no).
      set row_no to row_no + 1.
      print_line(round(engine:thrust, 1) + " kN", 10, row_no).
      set row_no to row_no + 2.
    }
    if not flaps:empty {
      set row_no to row_no + 1.
      for flap in flaps {
        print_line(round(flap_get_angle(flap), 1) + " deg", 9, row_no).
        set row_no to row_no + 2.
      }
    }
    print_line(round(ship_pitch(), 1) + " deg", 12, row_no).
    set row_no to row_no + 1.
    print_line(round(ship_yaw(), 1) + " deg", 10, row_no).
    set row_no to row_no + 1.
    print_line(round(ship_roll(), 1) + " deg", 11, row_no).
    set row_no to row_no + 1.
    print_line(round(ship_aoa(), 1) + " deg", 17, row_no).
    set row_not to row_no + 1.
  }

  local page is make_mfd_page(_render@, first).

  function _toggle_engines {
    for engine in engines {
      if not engine:ignition {
        engine:activate().
      } else {
        engine:shutdown().
      }
    }
  }

  function _toggle_auto_flaps {
    main_cpu:connection:sendmessage("toggle_auto_flaps").
  }

  function _less_flaps {
    main_cpu:connection:sendmessage("less_flaps").
  }

  function _more_flaps {
    main_cpu:connection:sendmessage("more_flaps").
  }

  set_mfd_action(page, 4, _toggle_engines@).
  set_mfd_action(page, 5, _toggle_auto_flaps@).
  set_mfd_action(page, 6, _less_flaps@).
  set_mfd_action(page, 7, _more_flaps@).

  return page.
}

function make_first_engineering_mfd_page {
  parameter engines is list().
  parameter flaps is list().

  return make_engineering_mfd_page(engines, flaps, true).
}

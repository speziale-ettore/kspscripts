//
// science-mfd.ks: science mfd.
//

include("utils/science.ks").

function make_science_mfd_page {
  parameter science is list().
  parameter first is false.

  local science_cpu is false.
  if ship_haspart(ship_family() + "-science-cpu") {
    set science_cpu to processor(ship_family() + "-science-cpu").
  } else if ship_haspart("science-cpu") {
    set science_cpu to processor("science-cpu").
  } else {
    set science_cpu to processor(ship_family() + "-cpu").
  }

  function _render {
    parameter update.

    if not update {
      print "Experiments:".
      for experiment in science {
        print "  *. " + experiment:part:title + " -> ".
      }
      print " ".
      print "Actions:".
      print "  4. Run All".
      print "  5. Transmit All".
      print "  6. Reset All".
    }

    local row_no is 3.

    for experiment in science {
      local col_no is 5 + experiment:part:title:length + 4.
      print_line(round(science_data(experiment), 1) + " Mits, " +
                 round(science_transmit(experiment), 1) + "/" +
                 round(science_recovery(experiment), 1) + " Science",
                 col_no, row_no).
      set row_no to row_no + 1.
    }
  }

  local page is make_mfd_page(_render@, first).

  function _run_all {
    science_cpu:connection:sendmessage("run_all_experiments").
  }

  function _transmit_all {
    science_cpu:connection:sendmessage("transmit_all_experiments").
  }

  function _reset_all {
    science_cpu:connection:sendmessage("reset_all_experiments").
  }

  set_mfd_action(page, 4, _run_all@).
  set_mfd_action(page, 5, _transmit_all@).
  set_mfd_action(page, 6, _reset_all@).

  return page.
}

function make_first_science_mfd_page {
  parameter science is list().

  return make_science_mfd_page(science, true).
}

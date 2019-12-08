//
// science.ks: science utils.
//

include("utils/ship.ks").

function science_data {
  parameter science.

  local amount is 0.
  for data in science:data {
    set amount to data:dataamount.
  }

  return amount.
}

function science_transmit {
  parameter science.

  local value is 0.
  for data in science:data {
    set value to data:transmitvalue.
  }

  return value.
}

function science_recovery {
  parameter science.

  local value is 0.
  for data in science:data {
    set value to data:sciencevalue.
  }

  return value.
}

function run_all_experiments {
  parameter experiments.

  for experiment in experiments {
    if not experiment:hasdata and not experiment:inoperable {
      experiment:deploy().
    }
  }
}

function transmit_all_experiments {
  parameter experiments.

  local mits is 0.
  for experiment in experiments {
    if experiment:hasdata {
      set mits to mits + science_data(experiment).
    }
  }

  local transmit_cost is mits / ship_bandwidth() * ship_transmit_cost().
  if 0.75 * ship:electriccharge < transmit_cost {
    return.
  }

  for experiment in experiments {
    if homeconnection:isconnected {
      experiment:transmit().
    }
  }
}

function reset_all_experiments {
  parameter experiments.

  for experiment in experiments {
    if not experiment:inoperable {
      experiment:reset().
    }
  }
}

function make_science {
  parameter science is ship_science().

  function _messages {
    parameter mission.

    if core:messages:empty {
      return.
    }

    local msg is core:messages:peek().

    if msg:content = "run_all_experiments" {
      run_all_experiments(science).
      core:messages:pop().
    } else if msg:content = "transmit_all_experiments" {
      transmit_all_experiments(science).
      core:messages:pop().
    } else if msg:content = "reset_all_experiments" {
      reset_all_experiments(science).
      core:messages:pop().
    }
  }

  return _messages@.
}

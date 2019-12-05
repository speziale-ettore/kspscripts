//
// science.ks: science utils.
//

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

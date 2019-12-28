//
// engine.ks: engine utils.
//

function engine_fuel_flow {
  parameter engine.

  local amount is 0.
  for data in science:data {
    set amount to data:dataamount.
  }

  return amount.
}

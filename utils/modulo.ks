//
// modulo.ks: mathematical modulo.
//

function modulo {
  parameter a.
  parameter b.

  local c is mod(a, b).
  if c < 0 {
    set c to c + b.
  }

  return c.
}

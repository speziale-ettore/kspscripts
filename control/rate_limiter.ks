//
// rate_limiter.ks: signal rate limiter.
//

function make_rate_limiter {
  parameter slew_rate.
  parameter t0.
  parameter y0.

  return list(slew_rate, t0, y0).
}

function rate_limiter_update {
  parameter rl.
  parameter t.
  parameter x.

  if t = rl[1] {
    return rl[2].
  }

  local rate is (x - rl[2]) / (t - rl[1]).

  local y is 0.
  if rate > rl[0] {
    set y to (t - rl[1]) * rl[0] + rl[2].
  } else if rate < -rl[0] {
    set y to (t - rl[1]) * -rl[0] + rl[2].
  } else {
    set y to x.
  }

  set rl[1] to t.
  set rl[2] to y.

  return y.
}

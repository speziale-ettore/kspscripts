//
// clamp.ks: clamp numbers..
//

function clamp {
  parameter x.
  parameter a.
  parameter b.

  return min(max(x, a), b).
}

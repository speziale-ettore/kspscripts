//
// boot.ks: vessel bootloader.
//

set config:ipu to 2000.
wait until ship:unpacked.

function download {
  parameter f.
  parameter v is core:tag.

  if not ship:status = "prelaunch" and not ship:connection:isconnected {
    return false.
  }

  local downloaded is false.

  if exists("0:/" + f) {
    switch to v.
    copypath("0:/" + f, f).
    switch to core:tag.
    set downloaded to true.
  }

  return downloaded.
}

function include {
  parameter f.

  if not download(f) {
    notify_err("can't include '" + f + "'").
  }
  runoncepath(f).
}

function notify_info {
  parameter msg.
  hudtext("info: " + msg, 5, 2, 15, green, true).
}

function notify_err {
  parameter msg.
  hudtext("error: " + msg, 5, 2, 15, red, true).
}

core:messages:clear().
set ship:control:pilotmainthrottle to 0.
brakes on.

if not download("cpus/" + core:tag + ".ks") {
  notify_err("missing '" + core:tag + "' startup file").
} else {
  runpath("cpus/" + core:tag + ".ks").
}

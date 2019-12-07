//
// boot.ks: vessel bootloader.
//

set config:ipu to 2000.
wait until ship:unpacked.

function download {
  parameter f.
  parameter g is core:volume + ":/" + f.

  if not ship:status = "prelaunch" and not ship:connection:isconnected {
    return false.
  }

  local downloaded is false.

  if exists("0:/" + f) {
    copypath("0:/" + f, g).
    set downloaded to true.
  }

  return downloaded.
}

function include {
  parameter f.

  if not download(f) {
    notify_err("can't include '" + f + "'").
  }
  runoncepath(core:volume + ":/" + f).
}

function notify_info {
  parameter msg.
  hudtext("info: " + msg, 5, 2, 15, green, true).
}

function notify_err {
  parameter msg.
  hudtext("error: " + msg, 5, 2, 15, red, true).
}

set ship:control:pilotmainthrottle to 0.
brakes on.

if not download("cpus/" + core:tag + ".ks", core:volume + ":/startup.ks") {
  notify_err("missing '" + core:tag + "' startup file").
} else {
  runpath(core:volume + ":/startup.ks").
}

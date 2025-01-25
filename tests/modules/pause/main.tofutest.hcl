run "valid_100s" {
  command = plan
  variables {
    create_duration  = "100s"
    destroy_duration = "100s"
  }
}

run "valid_1h" {
  command = plan
  variables {
    create_duration  = "1h"
    destroy_duration = "1h"
  }
}

run "valid_10m" {
  command = plan
  variables {
    create_duration  = "10m"
    destroy_duration = "10m"
  }
}

run "valid_10000000ms" {
  command = plan

  variables {
    create_duration  = "10000000ms"
    destroy_duration = "10000000ms"
  }
}

run "invalid_duration" {
  command = plan

  variables {
    create_duration  = "nonsense"
    destroy_duration = "nonsense"
  }

  expect_failures = [
    var.create_duration,
    var.destroy_duration,
  ]
}

# Time provider does not accept d, ns, or µs units, nor does it accept compound values.
run "invalid_10000000ns" {
  command = plan

  variables {
    create_duration  = "10000000ns"
    destroy_duration = "10000000ns"
  }

  expect_failures = [
    var.create_duration,
    var.destroy_duration,
  ]
}

run "invalid_10000000us" {
  command = plan

  variables {
    create_duration  = "10000000us"
    destroy_duration = "10000000us"
  }

  expect_failures = [
    var.create_duration,
    var.destroy_duration,
  ]
}

run "invalid_10000000µs" {
  command = plan

  variables {
    create_duration  = "10000000\\u00b5s"
    destroy_duration = "10000000\\u03bcs"
  }

  expect_failures = [
    var.create_duration,
    var.destroy_duration,
  ]
}

run "invalid_1d_duration" {
  command = plan

  variables {
    create_duration  = "1d"
    destroy_duration = "1d"
  }

  expect_failures = [
    var.create_duration,
    var.destroy_duration,
  ]
}

run "invalid_1h30m15s" {
  command = plan

  variables {
    create_duration  = "1h30m15s"
    destroy_duration = "1h30m15s"
  }

  expect_failures = [
    var.create_duration,
    var.destroy_duration,
  ]
}


run "default" {
  command = apply

  assert {
    condition     = length(time_sleep.pause) == 0
    error_message = "Expected no pause resources, got ${length(time_sleep.pause)}"
  }
}

run "create" {
  command = apply

  variables {
    create_duration = "5s"
  }

  assert {
    condition     = length(time_sleep.pause) == 1
    error_message = "Expected one pause resource, got ${length(time_sleep.pause)}"
  }

  assert {
    condition     = alltrue([for k, v in time_sleep.pause : v.create_duration == "5s"])
    error_message = "Expected create_duration to be 5s, got '${join(",", compact([for k, v in time_sleep.pause : v.create_duration]))}'"
  }

  assert {
    condition     = alltrue([for k, v in time_sleep.pause : v.destroy_duration == null])
    error_message = "Expected destroy_duration to be null, got '${join(",", compact([for k, v in time_sleep.pause : v.destroy_duration]))}'"
  }
}

run "destroy" {
  command = apply

  variables {
    destroy_duration = "5s"
  }

  assert {
    condition     = length(time_sleep.pause) == 1
    error_message = "Expected one pause resource, got ${length(time_sleep.pause)}"
  }

  assert {
    condition     = alltrue([for k, v in time_sleep.pause : v.create_duration == null])
    error_message = "Expected create_duration to be null, got ''${join(",", compact([for k, v in time_sleep.pause : v.create_duration]))}'"
  }

  assert {
    condition     = alltrue([for k, v in time_sleep.pause : v.destroy_duration == "5s"])
    error_message = "Expected destroy_duration to be 5s, got '${join(",", compact([for k, v in time_sleep.pause : v.destroy_duration]))}'"
  }
}

run "both" {
  command = apply

  variables {
    create_duration  = "5s"
    destroy_duration = "5s"
  }

  assert {
    condition     = length(time_sleep.pause) == 1
    error_message = "Expected one pause resource, got ${length(time_sleep.pause)}"
  }

  assert {
    condition     = alltrue([for k, v in time_sleep.pause : v.create_duration == "5s"])
    error_message = "Expected create_duration to be 5s, got '${join(",", compact([for k, v in time_sleep.pause : v.create_duration]))}'"
  }

  assert {
    condition     = alltrue([for k, v in time_sleep.pause : v.destroy_duration == "5s"])
    error_message = "Expected destroy_duration to be 5s, got '${join(",", compact([for k, v in time_sleep.pause : v.destroy_duration]))}'"
  }
}

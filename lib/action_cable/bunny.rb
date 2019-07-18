# frozen_string_literal: true

require "action_cable/bunny/version"
require "action_cable"

# We cannot move subscription adapter under `bunny/` path,
# `cause Action Cable uses this path when resolving an
# adapter from its name (in the config.yml)
require "action_cable/subscription_adapter/bunny"

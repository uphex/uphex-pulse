require 'bcrypt'
require 'active_support/core_ext/kernel/reporting'

# Reduce bcrypt running time by lowering the default cost.
Kernel.silence_warnings {
  BCrypt::Engine::DEFAULT_COST = BCrypt::Engine::MIN_COST
}

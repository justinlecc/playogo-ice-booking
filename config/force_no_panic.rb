# config/force_no_panic.rb
# Load bundler so gems are resolvable, then AR + PG adapter, then patch.
begin
  require 'bundler/setup'
rescue LoadError
end

begin
  require 'active_record'
  require 'active_record/connection_adapters/postgresql_adapter'

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
    def client_min_messages=(level)
      level = 'warning' if level.to_s == 'panic'
      execute("SET client_min_messages TO '#{level}'", 'SCHEMA')
    end
  end
rescue LoadError
  # If AR isn't loaded yet, we'll still get required by RUBYOPT early in boot,
  # and rake/rails will require AR soon after; the class_eval above will work once AR is present.
end


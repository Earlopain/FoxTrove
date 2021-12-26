# TODO: Remove when default in Rails (7.1?)
require "active_record/connection_adapters/postgresql_adapter"
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type = :timestamptz

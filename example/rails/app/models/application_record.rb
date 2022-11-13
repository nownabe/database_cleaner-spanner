require "composite_primary_keys"

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
class Job < ApplicationRecord
end
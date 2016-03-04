class PageView < ActiveRecord::Base
  belongs_to :viewer
  has_many :page_actions
end

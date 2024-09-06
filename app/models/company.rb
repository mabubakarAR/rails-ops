class Company < ApplicationRecord
  has_many :jobs
  validates :name, :email, presence: true
end

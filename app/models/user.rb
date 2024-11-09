class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: [ "user", "admin" ] }

  has_many :wallets, dependent: :destroy
  has_many :orders, dependent: :destroy
end

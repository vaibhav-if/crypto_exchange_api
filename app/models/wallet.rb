class Wallet < ApplicationRecord
  belongs_to :user
  validates :currency, presence: true, uniqueness: { scope: :user_id }
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def debit(amount)
    if balance >= amount
      self.balance -= amount
      save
    else
      errors.add(:balance, "Insufficient funds")
      false
    end
  end

  def credit(amount)
    self.balance += amount
    save
  end
end

class Order < ApplicationRecord
  belongs_to :user

  validates :side, presence: true, inclusion: { in: [ "buy", "sell" ] }
  validates :base_currency, presence: true
  validates :quote_currency, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :volume, numericality: { greater_than: 0 }

  before_create :validate_funds

  def validate_funds
    if side == "buy"
      validate_buy_funds
    elsif side == "sell"
      validate_sell_funds
    end
  end

  def validate_buy_funds
    wallet = user.wallets.find_by(currency: quote_currency)
    required_balance = price * volume
    if wallet && wallet.balance >= required_balance
      true
    else
      errors.add(:base, "Insufficient funds in #{quote_currency} wallet")
      false
    end
  end

  def validate_sell_funds
    wallet = user.wallets.find_by(currency: base_currency)
    if wallet && wallet.balance >= volume
      true
    else
      errors.add(:base, "Insufficient funds in #{base_currency} wallet")
      false
    end
  end
end

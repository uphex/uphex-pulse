class PortfolioRepository
  def self.for_user(user)
    user.organizations.map(&:portfolios).flatten
  end
end

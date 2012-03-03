module IntegrationSpecHelper
  def login_with_oauth(service = :twitter)
    visit "/auth/#{service}"
  end
end
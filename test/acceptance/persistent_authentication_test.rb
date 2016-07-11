require_relative '../acceptance_helper'

class PersistentAuthenticationTest < AcceptanceTestCase
  def setup
    super
    validator = SecureRandom.hex
    alice = User.create!(username: 'alice', github_id: 1, email: "alice@example.com", token_digest: Digest::SHA256.hexdigest(validator))
    @auth_token = AuthToken.create(selector: SecureRandom.hex, expiration: Time.now + 2592000, user_id: alice.id)
    Capybara.current_session.driver.browser.set_cookie("validator=#{validator}")
    Capybara.current_session.driver.browser.set_cookie("token=#{@auth_token.selector}")
  end

  def test_valid_cookies
    visit '/'

    assert_content 'alice'
  end

  def test_invalid_validator_cookie
    Capybara.current_session.driver.browser.set_cookie("validator=incorrectvalidator")
    visit '/'

    refute_content 'alice'
  end

  def test_invalid_token_cookie
    Capybara.current_session.driver.browser.set_cookie("token=invalidtoken")
    visit '/'

    refute_content 'alice'
  end

  def test_expired_auth_token
    @auth_token.update!(expiration: Time.now - 1000)
    visit '/'

    refute_content 'alice'
  end
end

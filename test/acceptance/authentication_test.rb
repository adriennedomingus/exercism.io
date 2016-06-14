require_relative '../acceptance_helper'

class AuthenticationTest < AcceptanceTestCase
  include Rack::Test::Methods
  include DBCleaner

  def app
    ExercismWeb::App
  end

  def test_can_auth_with_github
    user = User.create!(username: 'some_github_username',
                        github_id: 1234)
    with_login(user) do
      assert_content 'some_github_username'
    end
  end

  def test_user_remains_logged_in_with_cookies
    set_cookie "validator=1234"
    set_cookie "token=abcd"
    user = User.create!(username: 'some_github_username',
                        github_id: 1234,
                        token_digest: Digest::SHA256.hexdigest("1234"))
                        
    AuthToken.create(selector: "abcd",
                     user_id: user.id)

    visit '/'
    assert_content 'some_github_username'
    clear_cookies
  end
end

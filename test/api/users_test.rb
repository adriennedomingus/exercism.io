require_relative '../api_helper'

class UsersApiTest < Minitest::Test
  include Rack::Test::Methods
  include DBCleaner

  def app
    ExercismAPI::App
  end

  def test_users_query_sorts_alphabetically
    User.create(github_id: 1, username: 'Aliah')
    User.create(github_id: 3, username: 'Alicia')
    User.create(github_id: 2, username: 'Aisha')

    get '/user/find', { query: 'A' }

    assert_equal ['Aisha', 'Aliah', 'Alicia'], JSON.parse(last_response.body)
  end

  def test_users_query_is_case_insensitive
    User.create(username: 'Bill', github_id: 1)
    User.create(username: 'bob', github_id: 3)

    get '/user/find', { query: 'b' }

    assert_equal ['Bill', 'bob'], JSON.parse(last_response.body)
  end

  def test_users_query_sorts_participating_users_higher
    cassidy = User.create!(github_id: 1, username: 'cassidy')
    _ = User.create!(github_id: 2, username: 'christa')
    connie  = User.create!(github_id: 3, username: 'connie')

    submission = Submission.create!(user: User.create!)
    Comment.create!(submission: submission, body: 'test', user: cassidy)
    Comment.create!(submission: submission, body: 'test', user: connie)

    get '/user/find', { query: 'c', submission_key: submission.key }

    assert_equal ['cassidy', 'connie', 'christa'], JSON.parse(last_response.body)
  end

  def test_users_query_matches_based_on_start_of_username
    User.create!(github_id: 1, username: 'aa')
    User.create!(github_id: 1, username: 'ba')

    get '/user/find', { query: 'a' }

    assert_equal ['aa'], JSON.parse(last_response.body)
  end

  def test_empty_users_query
    User.create!(github_id: 1, username: 'whoever')

    get '/user/find', { query: '' }

    assert_equal [], JSON.parse(last_response.body)
  end

  def test_returns_completion_for_specific_user_by_language
    user = User.create(username: 'alice')
    submission = Submission.create(user: user, language: 'ruby', slug: 'leap', solution: {'leap.rb' => 'CODE'})
    UserExercise.create(user: user, submissions: [submission], language: 'ruby', slug: 'leap', iteration_count: 1)
    submission2 = Submission.create(user: user, language: 'javascript', slug: 'leap', solution: {'leap.js' => 'CODE'})
    UserExercise.create(user: user, submissions: [submission2], language: 'javascript', slug: 'leap', iteration_count: 1)
    submission3 = Submission.create(user: user, language: 'ruby', slug: 'bob', solution: {'bob.rb' => 'CODE'})
    UserExercise.create(user: user, submissions: [submission3], language: 'ruby', slug: 'bob', iteration_count: 1)

    get '/users/alice/statistics'

    response = JSON.parse(last_response.body)

    assert_equal 200, last_response.status
    assert_equal 45, response["statistics"].count
    assert_equal 2, response["statistics"]["Ruby"]["completed"]
    assert_equal 1, response["statistics"]["JavaScript"]["completed"]

    count = response["statistics"].select do |language, stats|
      stats["completed"] == 0
    end.count
    assert_equal 43, count
  end

  def test_returns_error_for_nonexistant_user
    get '/users/alice/statistics'

    response = JSON.parse(last_response.body)
    expected = "Sorry, something went wrong. We've been notified and will look into it."

    assert_equal 500, last_response.status
    assert_equal expected, response["error"]
  end
end

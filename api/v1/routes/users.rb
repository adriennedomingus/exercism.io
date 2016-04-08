module ExercismAPI
  module Routes
    class Users < Core
      # Looks up usernames by partial input.
      # Used from the web frontend when writing comments.
      get '/user/find' do
        content_type :json
        UserLookup.new(params).lookup.to_json
      end

      get '/users/:username/statistics' do |username|
        response = { user:
          { id: 1, username: "alice", email: nil, avatar_url: nil, github_id: nil
          },
          statistics: {
              ruby: {
                total: 66, completed: 1
                    },
              javascript: {
                total: 45, completed: 0
                          }
            }
        }
        response.to_json
      end
    end
  end
end

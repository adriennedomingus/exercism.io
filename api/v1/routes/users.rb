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
        user = User.find_by(username: username)
        hash = { user: user.public_user_attributes }
        statistics_hash = X::Track.all.map.with_object({}) do |track, statistics|
          statistics[track.language] = {total: track.problems.count, completed: user.exercises.where(language: track.language.downcase).count }
        end
        hash[:statistics] = statistics_hash
        hash.to_json
      end
    end
  end
end

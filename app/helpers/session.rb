module ExercismWeb
  module Helpers
    module Session
      def login(user)
        session[:github_id] = user.github_id
        set_persistent_cookies(user)
        @current_user = user
      end

      def logout
        session.clear
        cookies.delete(:token)
        cookies.delete(:validator)
        @current_user = nil
      end

      def current_user
        @current_user ||= logged_in_user || Guest.new
      end

      def login_url(return_path=nil)
        url = Github.login_url(client_id: github_client_id)
        url << redirect_uri(return_path) if return_path
        url
      end

      def please_login(notice=nil)
        if current_user.guest?
          flash[:notice] = notice if notice
          redirect link_to("/please-login?return_path=#{request.path_info}")
        end
      end

      private

      def redirect_uri(return_path)
        "&redirect_uri=http://#{host.chomp('/')}/github/callback#{return_path}"
      end

      def logged_in_user
        if session[:github_id]
          User.find_by(github_id: session[:github_id])
        elsif cookies[:token] && cookies[:validator]
          User.find_by_persistent_cookie(cookies[:token], cookies[:validator])
        end
      end

      def set_persistent_cookies(user)
        user.create_auth_token unless user.auth_token
        cookies[:token] = user.auth_token.selector
        cookies[:validator] = SecureRandom.hex
        user.update(token_digest: Digest::SHA256.hexdigest(cookies[:validator]))
        user.auth_token.update(expiration: Time.now + 2592000)
      end
    end
  end
end

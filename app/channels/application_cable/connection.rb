module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        token = request.headers[:HTTP_AUTHORIZATION]
        if token.present?
          decoded_token = decode_jwt(token)
          if decoded_token && (user_id = decoded_token["id"])
            return User.find_by(id: user_id)
          end
        else
          reject_unauthorized_connection
        end
      end
      
        def decode_jwt(token)
          begin
            JWT.decode(token, Rails.application.secrets.secret_key_base, true, algorithm: 'HS256').first
          rescue JWT::DecodeError
            nil
          end
        end
      end
  end


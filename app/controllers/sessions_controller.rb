class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]
  
  def new
  end
  
  def create
    user = User.find_by(username: session_params[:username])
  
    if user && user.authenticate(session_params[:password])
      token = User.generate_jwt(user.username)
      # render json: token.to_json
      puts "Generated JWT Token: #{token}"
      session[:jwt_token] = token
      puts "Session JWT Token Stored: #{session[:jwt_token]}"
      redirect_to user_path(user)
    else
      render json: { errors: { 'username or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

    def destroy
        logout_user
        redirect_to root_path, notice: "#{current_user&.username|| 'User'} has logged out successfully."
    end

  private

  # def generate_jwt(user)
  #   JWT.encode({ id: user.id, exp: 60.days.from_now.to_i }, ENV['DEVISE_JWT_SECRET_KEY'])
  # end

  def session_params
    params.except(:authenticity_token, :commit).permit(:username, :password)
  end

  def logout_user
    session.delete(:user_id)
    @current_user_id = nil
    cookies.delete(session[:jwt_token])
    puts "#{session[:jwt_token]}"
  end

end

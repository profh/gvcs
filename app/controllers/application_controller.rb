class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :fetch_incomplete_assignments, if: -> { !current_user.nil? && current_user.role?(:parent) }
  # current user, check 
  
    # just show a flash message instead of full CanCan exception
    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = "You are not authorized to perform this action."
      redirect_to home_path
    end

    # handle 404 errors with an exception as well
    rescue_from ActiveRecord::RecordNotFound do |exception|
      flash[:error] = "We apologize, but this information could not be found."
      redirect_to home_path
    end
  
    private
    # Handling authentication
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
    helper_method :current_user
  
    def logged_in?
      current_user
    end
    helper_method :logged_in?
  
    def check_login
      redirect_to login_path, alert: "You need to log in to view this page." if current_user.nil?
    end

    def fetch_incomplete_assignments
      @incomplete_assignments = Assignment.incomplete.for_parent(current_user.parent.id).paginate(page: params[:page]).per_page(15)
    end
  
  
  end
  
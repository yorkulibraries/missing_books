class RedirectorController < ApplicationController

  # SOLE JOB IS TO REDIRECT TO THE PROPER PLACE DEPENDING ON THE USER TYPE
  def index
    if params[:redirect_to_url]
      session[:redirect_to_url] = params[:redirect_to_url]
    end

    if session[:redirect_to_url] != nil
      url = session[:redirect_to_url]
      session[:redirect_to_url] = nil
      redirect_to url

    elsif session[:user_type] == Employee.new.class.name
      employee = Employee.find(session[:user_id])
      redirect_to default_employee_path(employee)
    else     
      patron = Patron.find(session[:user_id])
      redirect_to patron_my_tickets_path
    end
  end


  private
  def default_employee_path(employee)
    case employee.role
    when Employee::ROLE_LEVEL_ONE
      return sl1_dashboard_url
    when Employee::ROLE_LEVEL_TWO
      return sl2_dashboard_url
    when Employee::ROLE_COORDINATOR
      return coordinator_dashboard_url
    when Employee::ROLE_MANAGER
      return manager_dashboard_url
    else
      return dashboard_url
    end
  end
end

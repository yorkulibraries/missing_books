class Sl2::SearchTicketController < Sl2::AuthorizedBaseController

  before_action :load_search_ticket
  before_action :check_ticket_status, only: :update

  def show
      @work_log = SearchTicket::WorkLog.new
  end

  def edit
    @work_log = SearchTicket::WorkLog.new
    render action: :show
  end

  def update

    @work_log = SearchTicket::WorkLog.new(work_log_params)
    @work_log.work_type = SearchTicket::WorkLog::WORK_TYPE_SEARCH
    @work_log.employee = current_user
    @work_log.search_ticket = @ticket

    # add search_ticket id to searched_areas
    @work_log.searched_areas.each do |sa|
      sa.search_ticket = @ticket
    end

    if @work_log.save

      if @work_log.result == SearchTicket::WorkLog::RESULT_FOUND
        @ticket.status = SearchTicket::STATUS_RESOLVED
        @ticket.resolution = SearchTicket::RESOLUTION_FOUND
        @ticket.save

      elsif @work_log.result == SearchTicket::WorkLog::RESULT_NOT_FOUND
        @ticket.status = SearchTicket::STATUS_REVIEW_BY_COORDINATOR
        @ticket.assigned_to_id = nil
        @ticket.save
      end


      redirect_to sl2_search_ticket_path(@ticket), notice: "Work Log recorded"
    else
      render action: :show
    end
  end

  private

  def load_search_ticket
    @ticket = current_user.location.tickets.find(params[:id])
  end

  def check_ticket_status
    if @ticket.status != SearchTicket::STATUS_SEARCH_IN_PROGRESS
      redirect_to sl2_search_ticket_path(@ticket), notice: "This ticket hasn't been assigned to anyone yet."
    end
  end

  def work_log_params
     params.require(:search_ticket_work_log).permit(:result, :found_location, :note, search_area_ids: [])
  end

end

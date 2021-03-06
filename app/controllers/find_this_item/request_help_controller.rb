class FindThisItem::RequestHelpController < AuthenticatedPatronController
  layout "external_integration"

  def create
    item = JSON.parse(session[FindThisItem::LegalController::SESSION_ITEM_DATA])
    #item = JSON.parse(params[:item])

    ticket = SearchTicket.new(item)    
    ticket.patron = current_user


    # Ensure Location is properly matched. If not matched use the first location in the list
    # Later, we might add default import location attribute to the Location model.
    l  = Location.find_by_ils_code(ticket.item_location.strip)

    if l == nil
      dl = Location.where(default_location: true).first
      if dl != nil
        # Set it to default location
        l = dl
      else
        # Create New Location and Set it to default
        l = Location.create(name:ticket.item_location.strip, email: "something@somthing.com", ils_code: ticket.item_location.strip, default_location: true)
      end
    end

    ticket.location = l
    ticket.status = SearchTicket::STATUS_NEW

    if ticket.save
      redirect_to find_this_item_request_help_url(ticket_id: ticket.id)
    else
      puts ticket.errors.messages
      redirect_to find_this_item_legal_url(error: "THERE WAS AN ERROR #{ticket.error.messages}")
    end

  end

  def show

    if (session[FindThisItem::LegalController::SESSION_ITEM_DATA])


      @ticket = build_new_ticket
      @ticket.inspect
      # save the ticket
      if @ticket.save

        session[FindThisItem::LegalController::SESSION_ITEM_DATA] = nil
      else
        puts @ticket.errors.messages
        redirect_to find_this_item_legal_url(error: "THERE WAS AN ERROR #{@ticket.errors.messages}", item: session[FindThisItem::LegalController::SESSION_ITEM_DATA])
      end
    else

      @ticket = current_user.search_tickets.find(params[:ticket_id])
    end


    @referer_url = session[FindThisItem::LegalController::SESSION_REFERER_ID]
    session[:temp_ticket_id] = nil
  end

  private
  def build_new_ticket
    item = JSON.parse(session[FindThisItem::LegalController::SESSION_ITEM_DATA])

    ticket = SearchTicket.new(item)

    ticket.patron = current_user

    # Ensure Location is properly matched. If not matched use the first location in the list
    # Later, we might add default import location attribute to the Location model.
    l  = Location.find_by_ils_code(ticket.item_location.strip)

    if l == nil
      dl = Location.where(default_location: true).first
      if dl != nil
        # Set it to default location
        l = dl
      else
        # Create New Location and Set it to default
        l = Location.create(name:ticket.item_location.strip, email: "something@somthing.com", ils_code: ticket.item_location.strip, default_location: true)
      end
    end

    ticket.location = l
    ticket.status = SearchTicket::STATUS_NEW

    return ticket
  end


end

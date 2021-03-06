module TicketGeneratorHelper

  # Generates Ticket Params from Ticket. Used for testing purposes
  def generate_ticket_params(ticket, location=nil, patron=nil)
    require 'json'

    params = Hash.new
    params[:search_ticket] = ticket.attributes.slice("item_title", "item_callnumber", "item_author", "item_id", "item_volume", "item_issue", "item_year")
    params[:location] = location
    params[:patron] = patron.attributes.slice("name", "email", "login_id")
    return params
  end

  def generate_new_ticket_json(ticket)
    attrs = ticket.attributes.slice("item_location", "item_title", "item_callnumber", "item_author", "item_id", "item_volume", "item_issue", "item_year")
    return attrs.to_json
  end
end

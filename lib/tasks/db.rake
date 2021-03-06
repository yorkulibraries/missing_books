

namespace :db do
  desc "Prepopulate Some Data"
  task populate: :environment do
    require 'faker'
    require 'populator'

    # CLEAR THE DATABASE FIRST
    [SearchTicket, Patron, Employee, Location, SearchArea, SearchTicket::WorkLog, SearchTicket::SearchedArea].each(&:delete_all)

    ils_codes = ["SCOTT", "STEACIE", "FROST", "BRONFMAN"]
    location_names = ["Scott Library", "Steacie Library", "Frost Library", "Bronfman Library"]

    Location.populate(4) do |l|
      l.name = location_names.pop
      l.address = Faker::HarryPotter.house
      l.email = Faker::Internet.safe_email(l.name)
      l.phone = Faker::PhoneNumber.extension
      l.ils_code = ils_codes.pop

      SearchArea.populate(4..8) do |sa|
        sa.name = Faker::Job.field
        sa.location_id = l.id
        sa.primary = [true, false]
      end
    end

    location_ids = Location.ids
    roles = Employee::ROLES

    # Has to manually add employees in order to generate patron accounts for them
    roles.each_with_index do |role, index|
      e = Employee.new
      e.name = Faker::FamilyGuy.unique.character
      e.email = Faker::Internet.safe_email(e.name)
      e.role = role
      e.login_id = "111000222000#{index}"
      e.location_id = location_ids.pop
      e.active = true
      e.save
      puts "Adding Employee With Role: #{role}"
    end

    employee_ids = Employee.ids

    Patron.populate(10) do |patron|
      patron.name = Faker::GameOfThrones.character
      patron.email = Faker::Internet.safe_email(patron.name)
      patron.login_id = Faker::Number.unique.number(9)
    end

    patron_ids = Patron.ids
    location_ids = Location.ids

    SearchTicket::STATUSES.each do |status|

      SearchTicket.populate(10..15) do |report|
        # :item_id :item_callnumber :item_title :patron_id :location_id  :resolution :status  :note
        report.location_id = location_ids
        letters = Faker::Lorem.word[0..1]
        report.item_callnumber = "#{letters} #{Faker::Number.number(3)} #{letters.first}#{Faker::Number.number(3)} #{Faker::Number.between(1957,2017)}".upcase

        report.item_title = Faker::Book.unique.title
        report.item_author = Faker::Book.unique.author
        report.item_issue = ["March", "Jan", "September", "Jun"]
        report.item_volume = ["v1", "v2", "vol 3"]
        report.item_year = 1998..2017
        report.item_id = 39007031170798..39009011170792
        report.item_location = Location.find(report.location_id).ils_code
        report.patron_id = patron_ids

        report.status = status
        report.note = Faker::WorldOfWarcraft.quote
        report.assigned_to_id = 0

        if status == SearchTicket::STATUS_SEARCH_IN_PROGRESS
          # only assign if status is search_in_progress
          report.assigned_to_id = employee_ids
        end

        if status == SearchTicket::STATUS_ESCALATED_TO_LEVEL_2 || status == SearchTicket::STATUS_REVIEW_BY_COORDINATOR
          size = 1 if status == SearchTicket::STATUS_ESCALATED_TO_LEVEL_2
          size = 2 if status == SearchTicket::STATUS_REVIEW_BY_COORDINATOR

          SearchTicket::WorkLog.populate(2) do |log|
            #:search_ticket_id :employee_id :result :found_location :note, :work_type
            log.search_ticket_id = report.id
            log.employee_id = employee_ids
            log.result = SearchTicket::WorkLog::RESULTS
            log.found_location =  Location.find(report.location_id).ils_code
            log.note = Faker::WorldOfWarcraft.quote
          end
        end


        if status == SearchTicket::STATUS_RESOLVED
          report.resolution = SearchTicket::RESOLUTIONS
        else
          report.resolution = SearchTicket::RESOLUTION_UNKNOWN
        end


      end

    end # Statuses loop

    ## LOOP through the Search Tickets and fix locations for assigned tickets
    ## Locations should be the same as assigned_to user's locaiton
    SearchTicket.where.not(assigned_to_id: 0).each do |t|
      t.location = t.assigned_to.location
      t.save
    end

  end # END OF TASK

end # End of Namespace db

class Koha
  def self.send_subscription_reserve(obj, subscription_id: nil, filename: nil, performer_borrowernumber: nil)
    reserve_obj = {
      login_userid: APP_CONFIG['koha']['user'],
      login_password: APP_CONFIG['koha']['password'],
      reserve_id: filename,
      borrowernumber: obj[:borrowernumber],
      biblionumber: obj[:bibid],
      subscriptionid: subscription_id,
      branchcode: obj[:pickup_location_id],
      reservenotes: self.reserve_notes(obj[:description], obj[:loantype], obj[:extra_info]),
      performer_borrowernumber: performer_borrowernumber
    }

    # Send to KOHA svc store-subscription. To prevent blocking, run it in another thread
    Thread.new do
      url = "#{APP_CONFIG['koha']['base_url']}/reserves/store-subscription"
      response = RestClient.post url, reserve_obj
    end
  end

  def self.reserve_notes(description, loantype, extra_info)
    reservenotes_arr = []
    reservenotes_arr.push(description) if description.present?
    reservenotes_arr.push("Lånetyp: #{loantype}") if loantype.present?
    reservenotes_arr.push(extra_info) if extra_info.present? # Not used for subscription reserves ?
    return reservenotes_arr.compact.join("\n")
  end
end
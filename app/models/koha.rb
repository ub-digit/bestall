class Koha
  def self.send_statistics_from_subscription_object(obj, performer_borrowernumber: nil)
    pickup = obj[:pickup_location_id]
    categorycode = obj[:categorycode]
    performer_borrowernumber = performer_borrowernumber
    biblionumber = obj[:bibid]
    title = obj[:title]
    author = obj[:author]
    callno = obj[:call_number]
    location = obj[:sublocation_id]
    homebranch = obj[:sublocation_id][0..1]
    send_statistics(pickup: pickup, categorycode: categorycode, performer_borrowernumber: performer_borrowernumber, biblionumber: biblionumber, title: title, author: author, callno: callno, location: location, homebranch: homebranch)
  end

  def self.send_statistics(pickup:, categorycode:, performer_borrowernumber: nil, biblionumber:, title:, author: nil, callno: nil, location:, homebranch:)
    stat_obj = {
      userid: APP_CONFIG['koha']['user'],
      password: APP_CONFIG['koha']['password'],
      branch: pickup,
      type: 'hold_sub',
      other: homebranch,
      location: location,
      biblionumber: biblionumber,
      title: title,
      author: author,
      callno: callno,
      categorycode: categorycode,
      borrowernumber: performer_borrowernumber
    }

    # Send to KOHA svc "ub_statistics". To prevent blocking, run it in another thread
    Thread.new do
      url = "#{APP_CONFIG['koha']['base_url']}/ub_statistics"
      response = RestClient.post url, stat_obj
    end
  end
end
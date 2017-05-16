class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/resource-updates')
    .description("Get list of uris for published resources updated / deleted since timestamp")
    .params(["modified_since", Integer, "The modified since timestamp", :required => true])
    .permissions([])
    .returns([200, :ok],
             [400, :error]) \
  do
    resource_updates = get_resource_updates_for_timestamp params[:modified_since]
    json_response(resource_updates)
  end

  def get_resource_updates_for_timestamp(ts)
    modified_since_time = Time.at(ts)
    resource_updates    = {
      deleted: [],
      updated: [],
      time: {
        modified_since_time: modified_since_time,
        timestamp: ts,
      },
    }

    DB.open do |db|
      resource_updates[:updated] = db[:resource_update].where(
        publish: 1,
        suppressed: 0,
      ){system_mtime >= modified_since_time}.select(:uri).group(:id).all

      resource_updates[:deleted] = db[:resource_delete].where{
        timestamp >= modified_since_time
      }.select(:uri).all
    end

    resource_updates
  end

end

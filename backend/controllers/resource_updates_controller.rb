class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/resource-updates')
    .description("Get list of uris for published resources updated / deleted since timestamp")
    .params(["modified_since", Integer, "The modified since timestamp", :required => true])
    .permissions([])
    .returns([200, :ok],
             [400, :error]) \
  do
    resource_updates = ArchivesSpace::ResourceUpdate.updates_since params[:modified_since]
    json_response(resource_updates)
  end

end

module ArchivesSpace

  class ResourceUpdate

    def self.updates_since(ts)
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

end
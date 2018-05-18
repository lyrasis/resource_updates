module ArchivesSpace

  class ResourceUpdate

    def self.updates_since(ts)
      # local server, db session and instance (archivesspace)
      # timezones may be different so use UTC throughout
      modified_since_time = Time.at(ts).utc
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
          "CONVERT_TZ(user_mtime, @@session.time_zone, '+00:00') >= :mst AND publish = 1 and suppressed = 0",
          mst: modified_since_time
        ).distinct.select(:uri).all

        resource_updates[:deleted] = db[:resource_delete].where(
          "CONVERT_TZ(timestamp, @@session.time_zone, '+00:00') >= :mst",
          mst: modified_since_time
        ).select(:uri).all
      end

      resource_updates
    end

  end

end

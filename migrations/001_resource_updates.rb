require "db/migrations/utils"

Sequel.migration do

  up do
    self << %{
CREATE OR REPLACE VIEW resource_update_via_r AS
  SELECT DISTINCT CONCAT('/repositories/', r.repo_id, '/resources/', r.id) as uri,
    r.id, r.repo_id, r.publish, r.suppressed, r.system_mtime
  FROM resource r
    }

    self << %{
CREATE OR REPLACE VIEW resource_update_via_ao AS
  SELECT DISTINCT CONCAT('/repositories/', r.repo_id, '/resources/', r.id) as uri,
    r.id, r.repo_id, r.publish, r.suppressed, ao.system_mtime
  FROM resource r
  JOIN archival_object ao on ao.root_record_id = r.id
    }

    self << %{
CREATE OR REPLACE VIEW resource_update_via_do AS
  SELECT DISTINCT CONCAT('/repositories/', r.repo_id, '/resources/', r.id) as uri,
    r.id, r.repo_id, r.publish, r.suppressed, do.system_mtime
  FROM digital_object do
  JOIN instance_do_link_rlshp rlshp ON rlshp.digital_object_id = do.id
  JOIN instance i ON i.id = rlshp.instance_id
  JOIN resource r ON r.id = i.resource_id
    }

    self << %{
CREATE OR REPLACE VIEW resource_update_via_do_ao AS
  SELECT DISTINCT CONCAT('/repositories/', r.repo_id, '/resources/', r.id) as uri,
    r.id, r.repo_id, r.publish, r.suppressed, do.system_mtime
  FROM digital_object do
  JOIN instance_do_link_rlshp rlshp ON rlshp.digital_object_id = do.id
  JOIN instance i ON i.id = rlshp.instance_id
  JOIN archival_object ao ON ao.id = i.archival_object_id
  JOIN resource r ON r.id = ao.root_record_id
    }

    self << %{
CREATE OR REPLACE VIEW resource_update_via_doc AS
  SELECT DISTINCT CONCAT('/repositories/', r.repo_id, '/resources/', r.id) as uri,
    r.id, r.repo_id, r.publish, r.suppressed, doc.system_mtime
  FROM digital_object_component doc
  JOIN digital_object do ON doc.root_record_id = do.id
  JOIN instance_do_link_rlshp rlshp ON rlshp.digital_object_id = do.id
  JOIN instance i ON i.id = rlshp.instance_id
  JOIN resource r ON r.id = i.resource_id
    }

    self << %{
CREATE OR REPLACE VIEW resource_update_via_doc_do_ao AS
  SELECT DISTINCT CONCAT('/repositories/', r.repo_id, '/resources/', r.id) as uri,
    r.id, r.repo_id, r.publish, r.suppressed, doc.system_mtime
  FROM digital_object_component doc
  JOIN digital_object do ON doc.root_record_id = do.id
  JOIN instance_do_link_rlshp rlshp ON rlshp.digital_object_id = do.id
  JOIN instance i ON i.id = rlshp.instance_id
  JOIN archival_object ao ON ao.id = i.archival_object_id
  JOIN resource r ON r.id = ao.root_record_id
    }

    self << %{
CREATE OR REPLACE VIEW resource_update AS
  SELECT * FROM resource_update_via_r
  UNION
  SELECT * FROM resource_update_via_ao
  UNION
  SELECT * FROM resource_update_via_do
  UNION
  SELECT * FROM resource_update_via_do_ao
  UNION
  SELECT * FROM resource_update_via_doc
  UNION
  SELECT * FROM resource_update_via_doc_do_ao
    }

    self << %{
CREATE OR REPLACE VIEW resource_delete AS
  SELECT uri, timestamp FROM deleted_records
  WHERE uri LIKE '/repositories/%/resources/%'
  AND uri NOT LIKE '%#%'
    }
  end

end
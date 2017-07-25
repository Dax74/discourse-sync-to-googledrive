module DiscourseBackupToDrive
  class DriveSynchronizer < Synchronizer
    CHUNK_SIZE = 25600000
    UPLOAD_MAX_SIZE = CHUNK_SIZE * 4

    def initialize(backup)
      super(backup)
      @session = GoogleDrive::Session.from_service_account_key(StringIO.new(@api_key))
    end

    protected
    def perform_sync
      full_path = backup.path
      filename = backup.filename
      file = @session.upload
      add_to_folder(@session, file)
      @session.root_collection.remove(file)
    end

    def add_to_folder(session, file)
      folder_name = Discourse.current_hostname
      folder = session.collection_by_title(folder_name)
      if folder.present?
        folder.add(file)
      else
        folder = session.root_collection.create_subcollection(folder_name)
        folder.add(file)
      end
    end

    def upload(session, folder_name, filename, full_path, size)
      if size < UPLOAD_MAX_SIZE then
        @session.upload_from_file(full_path, filename)
      else
        chunked_upload(session, folder_name, filename, full_path)
      end
    end

    def chunked_upload(session, folder_name, filename, full_path)
      File.open(full_path) do |f|
        loops = f.size / CHUNK_SIZE

        cursor = @session.start_upload_session(f.read(CHUNK_SIZE))

        (loops-1).times do |i|
          @session.append_upload_session( cursor, f.read(CHUNK_SIZE) )
        end

        @session.finish_upload_session(cursor, "/#{folder_name}/#{file_name}", f.read(CHUNK_SIZE))
      end
    end
  end
end

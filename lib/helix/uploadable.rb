module Helix

  # Mixed-in to ORM classes that are capable of being uploaded.

  module Uploadable

    module ClassMethods

      def upload(file_name)
        RestClient.post(upload_server_name,
                        { file:       File.new(file_name.to_s, "rb") },
                        { multipart:  true } )
        http_close
      end

      def upload_server_name
        upload_get(:http_open)
      end

      def http_open
        upload_server_name
      end

      def upload_open
        upload_server_name
      end

      def http_close
        upload_get(:http_close)
      end

      def upload_close
        http_close
      end

      private

      def upload_get(action)
        url = config.build_url( resource_label: "upload_sessions",
                                guid:           config.signature(:ingest),
                                action:         action,
                                content_type:   "" )
        RestClient.get(url)
      end

    end

    def self.included(klass); klass.extend(ClassMethods); end

  end

end
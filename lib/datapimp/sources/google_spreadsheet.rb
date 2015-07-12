module Datapimp::Sources
  class GoogleSpreadsheet < Datapimp::Sources::Base
    requires :key

    attr_accessor :key,
                  :session,
                  :name

    def initialize name, options={}
      @options  = options

      if name.is_a?(GoogleDrive::Spreadsheet)
        @spreadsheet = name
        @name = @spreadsheet.title
        @key = @spreadsheet.key
      end

      @key      ||= options[:key]
      @session  ||= options.fetch(:session) { Datapimp::Sync.google.api }

      ensure_valid_options!
    end

    def self.create_from_file(path, title)
      if find_by_title(title)
        raise 'Spreadsheet with this title already exists'
      end

      session.upload_from_file(path, title, :content_type => "text/csv")

      find_by_title(title)
    end

    def self.[](key_or_title)
      find_by_key(key_or_title) || find_by_title(key_or_title)
    end

    def self.find_by_key(key)
      sheet = session_spreadsheets.detect do |spreadsheet|
        spreadsheet.key == key
      end

      sheet && new(sheet, session: Datapimp::Sync.google.session)
    end

    def self.find_by_title title
      sheet = session_spreadsheets.detect do |spreadsheet|
        spreadsheet.title.match(title)
      end

      sheet && new(sheet, session: Datapimp::Sync.google.session)
    end

    def self.session_spreadsheets
      @session_spreadsheets ||= Datapimp::Sync.google.api.spreadsheets
    end

    def self.create_from_data(data, options={})
      require 'csv'

      headers = Array(options[:headers]).map(&:to_s)

      tmpfile = "tmp-csv.csv"

      CSV.open(tmpfile, "wb") do |csv|
        csv << headers

        data.each do |row|
          csv << headers.map do |header|
            row = row.stringify_keys
            row[header.to_s]
          end
        end
      end

      spreadsheet = Datapimp::Sync.google.api.upload_from_file(tmpfile, options[:title], :content_type => "text/csv")

      new(spreadsheet.title, key: spreadsheet.key)
    end


    def title
      @name ||= spreadsheet.try(:title)
    end

    def edit_url
      spreadsheet.human_url
    end

    def share_write_access_with *emails
      acl = spreadsheet.acl

      Array(emails).flatten.each do |email|
        acl.push scope_type: "user",
                 with_key: false,
                 role: "writer",
                 scope: email
      end
    end

    def share_read_access_with *emails
      acl = spreadsheet.acl

      Array(emails).flatten.each do |email|
        acl.push scope_type: "user",
                 with_key: false,
                 role: "reader",
                 scope: email
      end
    end

    def add_to_collection collection_title
      collection = if collection_title.is_a?(GoogleDrive::Collection)
        collection_title
      else
        session.collections.find do |c|
          c.title == collection_title
        end
      end

      if !collection
        collection_names = session.collections.map(&:title)
        raise 'Could not find collection in Google drive. Maybe you mean: ' + collection_names.join(', ')
      end
    end

    def spreadsheet_key
      key
    end

    def stale?
      (!need_to_refresh? && (age > max_age)) || fresh_on_server?
    end

    def fresh_on_server?
      refreshed_at.to_i > 0 && (last_updated_at > refreshed_at)
    end

    def last_updated_at
      if value = spreadsheet.document_feed_entry_internal.css('updated').try(:text) rescue nil
        DateTime.parse(value).to_i
      else
        Time.now.to_i
      end
    end

    def fetch
      self.raw = process_worksheets
    end

    def preprocess
      single? ? raw.values.flatten : raw
    end

    protected

      def process_worksheets
        worksheets.inject({}.to_mash) do |memo, parts|
          k, ws = parts
          header_row = Array(ws.rows[0])
          column_names = header_row.map {|cell| "#{ cell }".parameterize.underscore }
          rows = ws.rows.slice(1, ws.rows.length)

          row_index = 1
          memo[k] = rows.map do |row|
            col_index = 0

            _record = column_names.inject({}) do |record, field|
              record[field] = "#{ row[col_index] }".strip
              record["_id"] = row_index
              col_index += 1
              record
            end

            row_index += 1

            _record
          end

          memo
        end
      end

      def single?
        worksheets.length == 1
      end

      def header_rows_for_worksheet key
        if key.is_a?(Fixnum)
          _worksheets[key]
        else
          worksheets.fetch(key)
        end
      end

      def worksheets
        @worksheets ||= _worksheets.inject({}.to_mash) do |memo,ws|
          key = ws.title.strip.downcase.underscore.gsub(/\s+/,'_')
          memo[key] = ws
          memo
        end
      end

      def _worksheets
        @_worksheets ||= spreadsheet.worksheets
      end

      def spreadsheet
        @spreadsheet ||= session.spreadsheet_by_key(spreadsheet_key)
      end
  end
end

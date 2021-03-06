require "faraday"
require "faraday_middleware"
require "faraday-cookie_jar"

module Ruboty
  module Actions
    class Jobcan
      NAMESPACE = "jobcan"

      attr_reader :message

      def initialize(message)
        @message = message
      end

      def remember_code
        user_data["code"] = message[:code]
        message.reply("I remember.")
      end

      def remember_group_id
        user_data["group_id"] = message[:group_id]
        message.reply("I remember.")
      end

      def punch_clock(in_out = :auto)
        unless (code = user_data["code"])
          message.reply("I don't know your JOBCAN code.")
          return
        end
        unless (group_id = user_data["group_id"])
          message.reply("I don't know your JOBCAN group ID.")
          return
        end
        client = JobcanClient.new(code, group_id, in_out)
        client.authenticate!
        status = client.punch_clock!
        message.reply("OK, your current status is #{status}.")
      rescue
        message.reply("Error: #{$!}")
      end

      def clock_in
        punch_clock(:in)
      end

      def clock_out
        punch_clock(:out)
      end

      private

      def user_data
        brain_space = message.robot.brain.data[NAMESPACE] ||= {}
        brain_space[message.from_name] ||= {}
      end

      class JobcanClient
        def initialize(code, group_id, in_out)
          @code = code
          @group_id = group_id
          @in_out = in_out
        end

        def authenticate!
          response = faraday.get(authenticate_url)
          unless response.status == 200
            fail "could not log in to JOBCAN; it returned #{response.status}"
          end
        end

        def punch_clock!
          response = faraday.post(punch_clock_url, punch_clock_request_body)
          unless response.status == 200
            fail "could not punch the clock on JOBCAN; it returned #{response.status}"
          end
          result = JSON.parse(response.body) or fail "could not parse response"
          if result["result"] == 0
            if result["errors"] && result["errors"]["aditCount"] == "duplicate"
              fail "you have punched the clock within a minute"
            end
            fail result["errors"].to_s
          end
          result["current_status"]
        end

        private

        def faraday
          @faraday ||= Faraday.new do |builder|
            # Note that the server will return JSON string with text/html content type.
            # Don't use `builder.response :json` here.
            builder.request :url_encoded
            builder.use FaradayMiddleware::FollowRedirects
            builder.use :cookie_jar
            builder.adapter Faraday.default_adapter
          end
        end

        def authenticate_url
          "https://ssl.jobcan.jp/employee?code=#{@code}"
        end

        def punch_clock_url
          "https://ssl.jobcan.jp/employee/index/adit"
        end

        def punch_clock_request_body
          { is_yakin: "0", adit_item: adit_item, adit_group_id: @group_id, notice: "" }
        end

        def adit_item
          case @in_out
          when :auto then "DEF"
          when :in then "work_start"
          when :out then "work_end"
          end
        end
      end
    end
  end
end

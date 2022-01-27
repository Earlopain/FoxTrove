module Scraper
  # This is unnecessarily convoluted. Let's hope Sofurry Next will actually happen sometime
  # https://wiki.sofurry.com/wiki/How_to_use_OTP_authentication
  class Sofurry < Base
    def init
      @page = 1
      @otp_sequence = 0
      @otp_pad = ""
      @otp_salt = ""
      @request_retries = 0

      user_json = make_request "https://api2.sofurry.com/std/getUserProfile", username: @identifier
      # TODO: Save this in the db. A few scraper can probably benefit from it as well
      @uid = user_json["userID"]
      @previous_ids = []
    end

    def enabled?
      Config.sofurry_user.present? && Config.sofurry_pass.present?
    end

    def fetch_next_batch
      json = make_request "https://api2.sofurry.com/browse/user/art", "uid": @uid, "art-page": @page, "format": "json"
      items = json["items"]
      ids = items.map { |item| item["id"] }
      # API always returns 30 items, could also use that to check, though I'm not sure if that will always be the case.
      # I don't trust this API at all. This will make one extra request, just to make sure.
      if ids == @previous_ids
        end_reached
        []
      else
        @previous_ids = ids
        @page += 1
        json["items"]
      end
    end

    def to_submission(submission)
      s = Submission.new
      s.identifier = submission["id"]
      s.title = submission["title"]
      s.description = Rails::Html::FullSanitizer.new.sanitize(submission["description"]) || ""
      created_at = extract_timestamp submission
      s.created_at = created_at

      s.add_file({
        url: "https://www.sofurryfiles.com/std/content?page=#{submission['id']}",
        created_at: created_at,
        identifier: "",
      })
      s
    end

    def extract_timestamp(submission)
      DateTime.strptime(submission["postTime"], "%s")
    end

    def make_request(url, **query)
      while true
        password_hash = Digest::MD5.hexdigest "#{Config.sofurry_pass}#{@otp_salt}"
        otp_hash = Digest::MD5.hexdigest "#{password_hash}#{@otp_pad}#{@otp_sequence}"
        response = HTTParty.get(url, {
          query: {
            otpuser: Config.sofurry_user,
            otphash: otp_hash,
            otpsequence: @otp_sequence,
            **query,
          },
        })
        json = JSON.parse(response.body)
        if json["messageType"] != 6
          @request_retries = 0
          @otp_sequence += 1
          return json
        end
        @request_retries += 1
        raise StandartError, "failed to authenticate" if @request_retries > 5

        @otp_sequence = json["newSequence"]
        @otp_pad = json["newPadding"]
        @otp_salt = json["salt"]
      end
    end
  end
end

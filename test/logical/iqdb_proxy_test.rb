# frozen_string_literal: true

require "test_helper"

class IqdbProxyTest < ActiveSupport::TestCase
  test "it makes the correct request when updating a submission" do
    sm = create(:submission_file_with_original, file_name: "1.jpg")
    sm.generate_variants

    request = stub_request(:post, "#{DockerEnv.iqdb_url}/images/#{sm.id}").to_return(status: 200, body: "{}", headers: { content_type: "application/json" })
    IqdbProxy.update_submission(sm)
    assert_requested(request)
  end

  test "it makes the correct request when deleting a submission" do
    sm = create(:submission_file)

    request = stub_request(:delete, "#{DockerEnv.iqdb_url}/images/#{sm.id}").to_return(status: 200)
    IqdbProxy.remove_submission(sm)
    assert_requested(request)
  end

  test "it makes the correct request when querying by submission" do
    sm = create(:submission_file_with_original, file_name: "1.jpg")
    sm.generate_variants

    similar_sm = create(:submission_file)
    similar = stub_iqdb(similar_sm => 70) do
      IqdbProxy.query_submission_file(sm)
    end
    assert_equal([{ score: 70, submission_file: similar_sm }], similar)
  end
end

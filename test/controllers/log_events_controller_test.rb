# frozen_string_literal: true

require "test_helper"

class IqdbControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    create(:log_event, payload: {
      method: "get",
      path: "foo.com",
      request_params: { params: { foo: "bar" } },
    })
    create(:log_event, payload: {
      method: "get",
      path: "foo.com",
      request_params: { body: "Hello World!" },
    })
    create(:log_event, payload: {
      method: "get",
      path: "foo.com",
      request_params: { json: { foo: "bar" } },
    })
    create(:log_event, payload: { method: "get", path: "foo.com" })
    get log_events_path
    assert_response :success
  end

  test "show for json response" do
    log_event = create(:log_event, payload: {
      method: "get",
      path: "foo.com",
      response_body: "{}",
    })
    get log_event_path(log_event)
    assert_response :success
  end

  test "show for non-json response" do
    log_event = create(:log_event, payload: {
      method: "get",
      path: "foo.com",
      response_body: "Hi!",
    })
    get log_event_path(log_event)
    assert_response :success
  end
end

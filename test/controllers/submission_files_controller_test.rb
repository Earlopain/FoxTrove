# frozen_string_literal: true

require "test_helper"

class SubmissionFilesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "index" do
    create(:submission_file_with_original, file_name: "1.jpg", with_sample: true)
    get submission_files_path
    assert_response :success
  end

  test "show" do
    sm = create(:submission_file_with_original, file_name: "1.jpg", with_sample: true)
    iqdb_sm = create(:submission_file_with_original, file_name: "1.webp")
    create(:e6_post, post_id: 1, submission_file: iqdb_sm, is_exact_match: false)
    create(:e6_post, post_id: 2, submission_file: iqdb_sm, is_exact_match: true)
    stub_iqdb(iqdb_sm => 80) do
      get submission_file_path(sm)
    end

    assert_response :success
  end

  test "show with a manual site type" do
    submission = create(:artist_submission, artist_url: create(:artist_url, site_type: "manual"))
    sm = create(:submission_file_with_original, artist_submission: submission, file_name: "1.jpg")
    get submission_file_path(sm)
    assert_response :success
  end

  test "show with sample not yet generated" do
    sm = create(:submission_file_with_original, file_name: "1.jpg", with_sample: false)
    get submission_file_path(sm)
    assert_response :success
  end

  test "modify backlock add" do
    sm = create(:submission_file)
    put modify_backlog_submission_file_path(sm, type: "add")

    assert_response :success
    assert sm.reload.added_to_backlog_at
  end

  test "modify backlock remove" do
    sm = create(:submission_file, added_to_backlog_at: Time.current)
    put modify_backlog_submission_file_path(sm, type: "remove")

    assert_response :success
    assert_nil sm.reload.added_to_backlog_at
  end

  test "modify hidden add" do
    sm = create(:submission_file)
    put modify_hidden_submission_file_path(sm, type: "add")

    assert_response :success
    assert sm.reload.hidden_from_search_at
  end

  test "modify hidden remove" do
    sm = create(:submission_file, hidden_from_search_at: Time.current)
    put modify_hidden_submission_file_path(sm, type: "remove")

    assert_response :success
    assert_nil sm.reload.hidden_from_search_at
  end

  test "last known good" do
    artist_url = create(:artist_url, last_scraped_at: Time.current)
    sm = create(:submission_file, artist_submission: create(:artist_submission, artist_url: artist_url), created_at_on_site: 7.days.ago)

    put set_last_known_good_submission_file_path(sm)
    assert_response :success
    assert_in_delta artist_url.reload.last_scraped_at, 8.days.ago, 1
  end

  test "update e6 posts" do
    sm1 = create(:submission_file_with_original, file_name: "1.jpg", with_sample: true)
    sm2 = create(:submission_file)
    create(:submission_file)

    stub_iqdb(sm2 => 90) do
      post update_e6_posts_submission_file_path(sm1)
    end

    assert_response :success
    assert_enqueued_jobs 2, only: E6IqdbQueryJob
  end

  test "update matching e6 posts" do
    post update_matching_e6_posts_submission_files_path(search: { artist_id: "123" })

    assert_response :success
    assert_enqueued_jobs 1
    assert_enqueued_with(job: UpdateMatchingE6PostsJob, args: [{ "artist_id" => "123" }])
  end

  test "backlog" do
    sm = create(:submission_file_with_original, file_name: "1.jpg", added_to_backlog_at: Time.current)
    create(:submission_file)

    get backlog_submission_files_path

    assert_response :success
    assert_select ".submission-sample", 1
    assert_select "[data-id='#{sm.id}']"
  end

  test "hidden" do
    sm = create(:submission_file_with_original, file_name: "1.jpg", hidden_from_search_at: Time.current)
    create(:submission_file)

    get hidden_submission_files_path

    assert_response :success
    assert_select ".submission-sample", 1
    assert_select "[data-id='#{sm.id}']"
  end

  test "hide many" do
    sm1, sm2 = create_list(:submission_file, 2)
    sm3 = create(:submission_file)

    put hide_many_submission_files_path(ids: [sm1, sm2])
    assert_response :success
    assert_not_nil(sm1.reload.hidden_from_search_at)
    assert_not_nil(sm2.reload.hidden_from_search_at)
    assert_nil(sm3.reload.hidden_from_search_at)

    assert_no_changes(-> { sm1.reload.hidden_from_search_at }, from: sm1.hidden_from_search_at) do
      assert_no_changes(-> { sm2.reload.hidden_from_search_at }, from: sm2.hidden_from_search_at) do
        put hide_many_submission_files_path(ids: [sm1, sm2, sm3])
      end
    end
    assert_response :success
    assert_not_nil(sm3.reload.hidden_from_search_at)
  end

  test "backlog many" do
    sm1, sm2 = create_list(:submission_file, 2)
    sm3 = create(:submission_file)

    put backlog_many_submission_files_path(ids: [sm1, sm2])
    assert_response :success
    assert_not_nil(sm1.reload.added_to_backlog_at)
    assert_not_nil(sm2.reload.added_to_backlog_at)
    assert_nil(sm3.reload.added_to_backlog_at)

    assert_no_changes(-> { sm1.reload.added_to_backlog_at }, from: sm1.added_to_backlog_at) do
      assert_no_changes(-> { sm2.reload.added_to_backlog_at }, from: sm2.added_to_backlog_at) do
        put backlog_many_submission_files_path(ids: [sm1, sm2, sm3])
      end
    end
    assert_response :success
    assert_not_nil(sm3.reload.added_to_backlog_at)
  end

  test "enqueue many" do
    sm = create(:submission_file_with_original, file_name: "1.jpg", with_sample: true)
    create(:submission_file)
    stub_iqdb({}) do
      put enqueue_many_submission_files_path(ids: [sm.id])
    end

    assert_response :success
    assert_enqueued_jobs 1, only: E6IqdbQueryJob
    assert_enqueued_with(job: E6IqdbQueryJob, args: [sm])
  end
end

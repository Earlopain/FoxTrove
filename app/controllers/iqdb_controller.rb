# frozen_string_literal: true

class IqdbController < ApplicationController
  def index
  end

  def search
    @matches = query(params.fetch(:search, {}))
  end

  private

  def query(params)
    if params[:url].present?
      if (post_id = params[:url].scan(%r{https://(?:e621|e926)\.net/posts/(\d*)\??})&.flatten&.first)
        post_data = E6ApiClient.get_post(post_id)
        IqdbProxy.query_url(post_data.dig("sample", "url"))
      else
        IqdbProxy.query_url(params[:url])
      end
    elsif params[:file]
      IqdbProxy.query_file(params[:file])
    else
      []
    end
  end
end

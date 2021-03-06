require 'twitter'

class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    @tweet_text = URI.encode("I am #{current_user.mastodon.try(:uid)} on Mastodon! Find your Twitter friends in the fediverse")

    fetch_twitter_followees
    fetch_twitter_followers
    fetch_related_mastodons
  end

  def follow
    user = User.find(params[:id])
    mastodon_uid = user.authorizations.find_by(provider: :mastodon).uid
    mastodon_client.follow_by_uri(mastodon_uid)
    redirect_to friends_path, notice: "Successfully followed #{mastodon_uid} from your Mastodon account"
  rescue Mastodon::Error::Unauthorized
    redirect_to friends_path, alert: "The access token for your Mastodon account has expired or was revoked"
  end

  private

  def fetch_twitter_followees
    @twitter_friend_ids = Rails.cache.fetch("#{current_user.id}/twitter-friends", expires_in: 15.minutes) do
      twitter_client.friend_ids
    end
  end

  def fetch_twitter_followers
    @twitter_follower_ids = Rails.cache.fetch("#{current_user.id}/twitter-followers", expires_in: 15.minutes) do
      twitter_client.follower_ids
    end
  end

  def fetch_related_mastodons
    found_ids1 = Authorization.where(provider: :twitter, uid: @twitter_friend_ids.to_a)
    found_ids2 = Authorization.where(provider: :twitter, uid: @twitter_follower_ids.to_a)

    @name_map = Rails.cache.fetch("#{current_user.id}/mastodons-on-twitter", expires_in: 15.minutes) do
      twitter_client.users((found_ids1 + found_ids2).map(&:uid).map(&:to_i)).map { |u| [u.id.to_s, u] }.to_h
    end

    @friends   = User.where(id: found_ids1.map(&:user_id)).includes(:authorizations)
    @followers = User.where(id: found_ids2.map(&:user_id)).includes(:authorizations)
  end

  def twitter_client
    @twitter_client ||= Twitter::REST::Client.new do |config|
      authorization = current_user.authorizations.find_by(provider: :twitter)

      config.consumer_key        = ENV['TWITTER_CLIENT_ID']
      config.consumer_secret     = ENV['TWITTER_CLIENT_SECRET']
      config.access_token        = authorization.try(:token)
      config.access_token_secret = authorization.try(:secret)
    end
  end

  def mastodon_client
    authorization = current_user.authorizations.find_by(provider: :mastodon)
    _, domain = authorization.uid.split('@')
    @mastodon_client ||= Mastodon::REST::Client.new(base_url: "https://#{domain}", bearer_token: authorization.token)
  end
end

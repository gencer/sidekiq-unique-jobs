# frozen_string_literal: true

class MyUniqueJob
  include Sidekiq::Worker
  sidekiq_options queue: :customqueue, retry: true, retry_count: 10
  sidekiq_options unique: :until_executed, lock_expiration: 7_200

  def perform(one, two)
    [one, two]
  end
end

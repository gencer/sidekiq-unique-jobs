# frozen_string_literal: true

require 'sidekiq/testing'

module Sidekiq
  module Worker
    module ClassMethods
      # Clear all jobs for this worker
      def clear
        jobs.each do |item|
         SidekiqUniqueJobs::Unlockable.delete!(item)
        end

        Sidekiq::Queues[queue].clear
        jobs.clear
      end

      unless respond_to?(:execute_job)
        def execute_job(worker, args)
          worker.perform(*args)
        end
      end
    end

    module Overrides
      def self.included(base)
        base.extend Testing
        base.class_eval do
          class << self
            alias_method :clear_all_orig, :clear_all
            alias_method :clear_all, :clear_all_ext
          end
        end
      end

      module Testing
        def clear_all_ext
          clear_all_orig
          SidekiqUniqueJobs::Util.del('*', 1000, false)
        end
      end
    end

    include Overrides
  end
end

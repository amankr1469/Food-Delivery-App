module Middleware
class FoodInCartMiddleware
  include Sidekiq::ServerMiddleware
  include RedisHelper

  def call(worker_class, job, queue)
    if queue == "cart" 
      user_id = job['args'][0]
      if get_redis_data(user_id).nil?
         Rails.logger.info("User ID #{user_id} found in Redis. Job not enqueued.")
         return
      else
        yield
      end
    end
    yield
  end
end
end

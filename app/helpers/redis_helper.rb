module RedisHelper
  REDIS_EXPIRATION_TIME = 3.hours.to_i

  def get_redis_data(key)
    $redis.get(key)
  rescue => e
    Rails.logger.error("Redis error: #{e.message}")
    nil
  end

  def set_redis_data(key, payload)
    $redis.set(key, payload)
  rescue => e
    Rails.logger.error("Redis error: #{e.message}")
  end

  def set_expire_time(key, time)
    $redis.expire(key, time)
  rescue => e
    Rails.logger.error("Redis error: #{e.message}")
  end

  def get_cached_data(key)
    cached_data = get_redis_data(key)
    if cached_data.present?
      JSON.parse(cached_data, object_class: OpenStruct)
    else
      data = yield
      set_redis_data(key, data.to_json)
      set_expire_time(key, REDIS_EXPIRATION_TIME)
      data
    end
  end
end

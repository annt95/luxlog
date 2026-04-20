class RateLimiter {
  static final Map<String, DateTime> _timestamps = {};

  /// Returns true if the action is allowed, and updates the timestamp.
  /// Returns false if the action is restricted due to being within the cooldown period.
  /// 
  /// [key] should be a unique identifier for the action (e.g. 'like_photo_123')
  /// [cooldown] is the minimum duration required between consecutive actions.
  static bool canProceed(String key, Duration cooldown) {
    final now = DateTime.now();
    final lastAction = _timestamps[key];

    if (lastAction == null || now.difference(lastAction) > cooldown) {
      _timestamps[key] = now;
      return true;
    }
    return false;
  }
}

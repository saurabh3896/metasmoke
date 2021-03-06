every 3.minutes do
  runner 'SmokeDetector.check_smokey_status'
end

every 1.day do
  runner 'ReasonsHelper.check_for_inactive_reasons'
  runner 'ReasonsHelper.calculate_weights_for_flagging'
end

# Run moderator check about an hour before the spam waves.
# We don't want to run it *during* the spam wave,
# as that could cause us to get unrespected API backoffs.

every 1.day, :at => '2:00 am' do
  runner 'User.where.not(:api_token => nil).each(&:update_moderator_sites)'
end

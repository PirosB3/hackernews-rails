module PostsHelper
  def time_ago_in_words_short(time)
    seconds = (Time.current - time).to_i
    return "just now" if seconds < 60

    minutes = seconds / 60
    return "#{minutes} minute#{'s' if minutes != 1} ago" if minutes < 60

    hours = minutes / 60
    return "#{hours} hour#{'s' if hours != 1} ago" if hours < 24

    days = hours / 24
    return "#{days} day#{'s' if days != 1} ago" if days < 30

    months = days / 30
    "#{months} month#{'s' if months != 1} ago"
  end
end

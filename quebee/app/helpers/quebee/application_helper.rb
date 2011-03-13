module Quebee

module ApplicationHelper
  # HACKETY, HACK, HACK
  ENTITY_MAP = {
    '<' => '&lt;',
    '>' => '&gt;',
    '&' => '&amp;',
    "\n" => '&#x0A;',
  }.freeze

  def my_escape v
    v = v.to_s.gsub(/([<>&\n])/m) {| x | ENTITY_MAP[x] || x }
    v.html_safe
  end
    
  def my_text_area obj, name, slot, opts = { }
    opts[:name] ||= "#{name}[#{slot}]"
    str = '<textarea '
    opts.each do | k, v |
      str << "#{k}=\"#{h v.to_s}\" "
    end
    str << '>'
    v = obj.send(slot).to_s
    str << my_escape(v)
    str << '</textarea>'
    str.html_safe
  end

  def my_pre text, opts = { }
    str = '<pre '
    opts.each do | k, v |
      str << "#{k}=\"#{h v.to_s}\" "
    end
    str << '>'
    str << my_escape(text)
    str << '</pre>'
    str.html_safe
  end

  def my_synopsis text, max_size = 32
    text = text.to_s
    lines = text.split(/\n/).
      map{|x| x.gsub(/\A\s+|\s+\Z/, '') }.
      select{|x| ! x.empty?}

    if lines.size > 0 
      dots = true
    end
    line = lines.first
    if line.size >= max_size
      dots = true
    end
    if dots
      line = line[0, max_size - 4]
      line += ' ...'
    end
    line
  end

  
  def my_secs secs
    secs = secs.to_f
    time = Time.at(secs.to_i)
    case
    when secs < 1.second
      '%0.4f sec' % secs
    when secs < 60.second
      '%0.2f sec' % secs
    when secs < 1.hour
      time.strftime('%M:%S') + '.' + '%02d' % (secs * 100 % 100)
    when secs < 12.hour
      ('%dh ' % (secs / 1.hour)) + time.strftime('%M:%S')
    when secs < 24.hours
      '%0.1f hrs' % (secs / 1.hour)
    else
      '%0.1f days' % (secs / 1.day)
    end
  end

  def my_time time, now = Time.now
    time = time.to_time if Date === time
    time = Time.at(time.to_i) if Numeric === time

    diff = now - time
    if future = diff < 0
      diff = - diff
    end

    case
    when diff < 1.minute
      "#{'%0.1f' % diff} seconds #{future ? 'from now' : 'ago'}"
    when diff < 1.hour
      "#{(diff / 1.minute).to_i} minutes #{future ? 'from now' : 'ago'}"
    when diff < 24.hour && time.mday == now.mday
      time.strftime('%I:%M%p')
    when diff < 1.week
      (future ? 'next' : 'last') + time.strftime(' %A %I:%M%p')
    when diff < 1.month && time.month == now.month
      time.strftime('%m/%d')
    when diff < 1.year && time.year == now.year
      time.strftime('%m/%d')
    else
      time.strftime('%y/%m/%d')
    end
  end
end

end

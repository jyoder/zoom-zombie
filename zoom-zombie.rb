require 'time'

def run(meeting_id)
    while true
        if !within_core_hours?(Time.now)
            $stdout.puts("Not within core hours")
        elsif meeting_running?
            $stdout.puts("Meeting is running")
        else
            $stdout.puts("Joining meeting")
            join_meeting(meeting_id)
            sleep(10)
            start_zoom_video
        end

        sleep(30)
    end
end

def meeting_running?
    processes = `ps aux | grep zoom`
    processes.split("\n").any? do |process|
        process =~ %r{/Applications/zoom.us.app/Contents/Frameworks/cpthost.app/Contents/MacOS/CptHost.*-key \d+}
    end
end

def join_meeting(meeting_id)
    `open "zoommtg://zoom.us/join?confno=#{meeting_id}"`
end

def start_zoom_video
    `osascript start-zoom-video.scpt`
end

def within_core_hours?(now)
    beginning_of_core_hours(now) <= now && now <= end_of_core_hours(now)
end

def today(now)
    now.strftime('%Y-%m-%d')
end

def beginning_of_core_hours(now)
    Time.parse("#{today(now)} 07:30:00 PDT")
end

def end_of_core_hours(now)
    Time.parse("#{today(now)} 17:30:00 PDT")
end

if ARGV.length != 1
    $stderr.puts("Usage: #{$0} <meeting id>")
    exit(1)
end
meeting_id = ARGV[0]

run(meeting_id)

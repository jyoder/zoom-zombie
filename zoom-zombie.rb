require 'time'

def run(meeting_id)
    first_start = true
    while true
        if !within_core_hours?(Time.now)
            $stdout.puts("Not within core hours")
        elsif meeting_running?
            $stdout.puts("Meeting is running")
        else
            $stdout.puts("Joining meeting")
            join_meeting(meeting_id)
            sleep(10)
            if first_start
                $stdout.puts("First time starting Zoom - starting video")
                start_zoom_and_video
                first_start = false
            else
                $stdout.puts("Restarting Zoom - video should already be on")
                start_zoom
            end
        end

        sleep(30)
    end
end

def meeting_running?
    processes = `ps aux | grep zoom`
    processes.split("\n").any? do |process|
        process =~ %r{/Applications/zoom.us.app/Contents/Frameworks/CptHost.app/Contents/MacOS/CptHost -pid \d+ -evtname CptHost\d+ -key \d+}
    end
end

def join_meeting(meeting_id)
    `open "zoommtg://zoom.us/join?confno=#{meeting_id}"`
end

def start_zoom_and_video
    `osascript start-zoom.applescript`
    sleep(2)
    `osascript toggle-zoom-video.applescript`
end

def start_zoom
    `osascript start-zoom.applescript`
end

def within_core_hours?(now)
    beginning_of_core_hours(now) <= now && now <= end_of_core_hours(now)
end

def today(now)
    now.strftime('%Y-%m-%d')
end

def beginning_of_core_hours(now)
    Time.parse("#{today(now)} 08:30:00 PDT")
end

def end_of_core_hours(now)
    Time.parse("#{today(now)} 17:45:00 PDT")
end

if ARGV.length != 1
    $stderr.puts("Usage: #{$0} <meeting id>")
    exit(1)
end
meeting_id = ARGV[0]

run(meeting_id)

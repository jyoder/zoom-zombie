require 'time'

def run(meeting_id)
    first_start = true
    was_active_today = false
    last_check_date = today(Time.now)

    while true
        now = Time.now
        current_date = today(now)

        # Reset active status at the start of a new day
        if current_date != last_check_date
            was_active_today = false
            last_check_date = current_date
        end

        if !within_core_hours?(now)
            if was_active_today && now >= end_of_core_hours(now)
                $stdout.puts("Core hours ended after active day - shutting down system")
                shutdown_system
                exit(0)
            else
                $stdout.puts("Not within core hours - waiting")
            end
        elsif meeting_running?
            $stdout.puts("Meeting is running")
            was_active_today = true
        else
            $stdout.puts("Joining meeting")
            join_meeting(meeting_id)
            sleep(10)
            if first_start
                $stdout.puts("First time starting Zoom - starting video")
                start_zoom_and_video
                first_start = false
            else
                $stdout.puts("Restarting Zoom - ensuring video is enabled")
                start_zoom_and_video
            end
            was_active_today = true
        end

        sleep(30)
    end
end

def shutdown_system
    `pkill -9 -f "zoom.us"`
    sleep(5)
    
    `osascript -e 'tell application "System Events" to shut down'`
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
    Time.parse("#{today(now)} 08:00:00 PDT")
end

def end_of_core_hours(now)
    Time.parse("#{today(now)} 18:30:00 PDT")
end

if ARGV.length != 1
    $stderr.puts("Usage: #{$0} <meeting id>")
    exit(1)
end
meeting_id = ARGV[0]

run(meeting_id)

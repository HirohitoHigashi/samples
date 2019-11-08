$cursor_control = true

require "io/console"
require "timeout"

$fb = [ " "*20, " "*20, " "*20, " "*20 ]
$row = 0
$col = 0
$cursor_on = false
$cursor_blink = false
$mutex = Mutex.new


def get_key()
  Timeout.timeout( 10 ) {
    while ch = STDIN.getch
      exit if ch == "\x03"   # ^C

      if ch == "\e"
        rs, ws, es = IO.select([STDIN], [], [], 0.1)
        if rs && STDIN.getch == "["
          ch = STDIN.getch
        end
      end

      case ch
      when "A"; return :UP
      when "B"; return :DOWN
      when "C"; return :RIGHT
      when "D"; return :LEFT
      when "\r"; return :OK
      when "\e"; return :CANCEL
      when "r"; return :ROOT
      end
    end
  }

rescue Timeout::Error=>ex
  return nil
end


def lcd_location( row, col )
  return if row > 3
  return if col > 20

  lcd_write_cursor( false )
  $row = row
  $col = col
  lcd_write_cursor()
end


def lcd_puts( s )
  return if $row > 3
  return if $col > 20

  s1 = s[0, 20 - $col]

  $fb[$row][$col, s1.size] = s1
  $col += s1.size

  lcd_write_fb()
end


def lcd_clear()
  $fb = [ " "*20, " "*20, " "*20, " "*20 ]
  $row = 0
  $col = 0
  lcd_write_fb()
end



def lcd_write_fb()
  $mutex.synchronize {
    print "\e[2J\e[1;1H" if $cursor_control
    print "+", "-"*20, "+\n"
    4.times {|row|
      print "|#{$fb[row]}|\n"
    }
    print "+", "-"*20, "+\n"
  }
end

def lcd_write_cursor( blink_toggle = true )
  return  if !$cursor_control
  $mutex.synchronize {
    print "\e[#{$row+2};#{$col+2}H"
    print "\e[4m" if $cursor_on
    print "\e[7m" if $cursor_blink && blink_toggle
    print $fb[$row][$col], "\b\e[0m"
  }
end


def lcd_cursor_on( mode )
  return if !$cursor_control

  lcd_write_cursor( false )
  $cursor_on = (mode == 1)
  lcd_write_cursor()
end

def lcd_blink_on( mode )
  return if !$cursor_control

  lcd_write_cursor( false )
  $cursor_blink = (mode == 1)
  lcd_write_cursor()
end





Thread.new {
  sleep 0 if !$cursor_control

  blink_toggle = true
  while true
    if $cursor_on || $cursor_blink
      lcd_write_cursor( blink_toggle )
    end
    blink_toggle = !blink_toggle
    sleep 0.5
  end
}


print "\e[?25l"         # CURSOR OFF
END {
  print "\e[?25h"       # CURSOR ON
}

# coding: utf-8
#
# 20x4 キャラクタLCDを使った階層メニューサンプル
#
# 各画面の表示と動作に責任を持つ "Menu" クラスと、
# それを束ねて駆動する "MenuDriver" クラスに分かれている。
# 実際の動作をする各クラスは、Menuクラスをスーパークラスとし、以下のメソッドを持つ。
#  show         メニューに入る時に表示書き換えを主目的として呼ばれる
#  action       キー入力などのイベントをハンドルする。
#  at_exit      メニューから抜ける時に呼ばれる
#

MAX_MENU_STACK = 10
LCD_ROW = 4
LCD_COLUMN = 20

##
# メニュードライバ
#
class MenuDriver

  ##
  # constructor
  #
  def initialize( menu_root )
    @menu_root = menu_root
    @menu_stack = []
  end


  ##
  # drive
  #
  #@return [Menu]       アクションを起こしたメニュー
  #
  def drive()
    if @menu_stack.empty?
      @menu_stack.push( @menu_root )
    end
    res = @menu_stack.last.show()
    act_menu = @menu_stack.last

    while true
      case res
      when Menu
        switch_menu( res )
        break

      when :GOBACK
        @menu_stack.last.at_exit()
        @menu_stack.pop()
        break
      end

      key = get_key()
      if key == :ROOT && @menu_stack.last != @menu_root
        switch_menu( @menu_root )
        break
      end

      res = @menu_stack.last.action( key )
    end

    return act_menu
  end


  ##
  # 画面切り替え（次メニューへ遷移）
  #
  def switch_menu( menu )
    @menu_stack.last.at_exit()
    @menu_stack.push( menu )
    if @menu_stack.size > MAX_MENU_STACK
      @menu_stack.shift()
    end
  end

end



##
# メニュー　スーパークラス
#
class Menu
  attr_reader :name

  def initialize( name = nil )
    @name = name
  end

  ##
  # 画面表示
  #
  #@retval [NilClass]   アクションなし
  #@return [Symbol]     指定のアクション依頼 (e.g. :GOBACK)
  #@return [Menu]       メニューに遷移
  #
  def show()
    lcd_clear()
    lcd_puts("=[#{@name}]" + "="*LCD_COLUMN ) if @name
    draw_contents()
    return nil
  end


  ##
  # コンテンツの描画
  #
  def draw_contents()
  end


  ##
  # アクションを実行
  #
  #@param  [Symbol]     実行するアクション (e.g. :OK)
  #@return [Symbol]     指定のアクションを依頼 (e.g. :GOBACK)
  #@retval [NilClass]   アクションなし
  #@return [Menu]       指定のメニューに遷移
  #
  def action( ev )
    return (ev == :CANCEL) ? :GOBACK : nil
  end


  ##
  # メニューから抜ける時の処理
  #
  def at_exit()
  end
end



##
# メニュー選択
#
class MenuSelector < Menu
  attr_reader :menus
  attr_reader :selected

  def initialize( name )
    super
    @menus = []
    @display_start_index = 0
    @selected = 0
  end


  ##
  # メニューに追加
  #
  def add_menu( menu )
    @menus << menu
  end


  ##
  # 名前でメニューリストを検索
  #
  def []( name )
    @menus.each {|menu|
      return menu if menu.name == name
    }
    return nil
  end


  ##
  # コンテンツの描画
  #
  def draw_contents()
    return  if @menus.empty?

    idx = @display_start_index
    row = 1
    while row <= (LCD_ROW-1)
      break if !@menus[idx]
      lcd_location( row, 0 )
      lcd_puts( (@selected == idx ? ">" : " ") +
                 @menus[idx].name + " " * LCD_COLUMN )
      row += 1
      idx += 1
    end
  end


  ##
  # アクション
  # (note)
  #  上下キーで選択、:OKで確定、:CANCELで戻る。
  #
  def action( ev )
    case ev
    when :UP
      @selected -= 1  if @selected > 0
      @display_start_index -= 1  if @selected < @display_start_index
      draw_contents()

    when :DOWN
      @selected += 1  if @selected < @menus.size - 1
      @display_start_index += 1  if @selected >= (@display_start_index + 3)
      draw_contents()

    when :OK
      return @menus[@selected]

    when :CANCEL
      return :GOBACK
    end

    return nil
  end
end


##
# メッセージ表示専用ダイアログ
#
class MenuDialog < Menu

  def initialize( name, message )
    super(name)
    @messages = []
    @display_start_index = 0

    i = 0
    while msg = message[i, LCD_COLUMN]
      @messages << msg
      i += LCD_COLUMN
    end
  end

  def show
    lcd_clear()
    draw_contents()
    return nil
  end

  def draw_contents()
    idx = @display_start_index
    row = 0
    while row < LCD_ROW
      break if !@messages[idx]
      lcd_location( row, 0 )
      lcd_puts( @messages[idx] + " " * LCD_COLUMN )
      row += 1
      idx += 1
    end
  end

  def action( ev )
    case ev
    when :UP
      @display_start_index -= 1  if @display_start_index > 0
      draw_contents()

    when :DOWN
      @display_start_index += 1  if @display_start_index < (@messages.size - LCD_ROW)
      draw_contents()

    when :OK, :CANCEL
      return :GOBACK
    end

    return nil
  end
end


##
# タイムアウト付きのダイアログ
#
class MenuTimerDialog < MenuDialog

  def initialize( name, msg, timeout )
    super( name, msg )
    @timeout = timeout
  end

  def show()
    super
    sleep @timeout
    return :GOBACK
  end
end


##
# YES/NO選択ダイアログ
#
class MenuConfirm < Menu
  attr_accessor :select
  attr_accessor :selected

  def initialize( name, message )
    super(name)
    @messages = message.split("\n")
    @select = :YES
  end

  def show()
    lcd_clear()
    i = 0
    while i < 2
      lcd_location( i, 0 )
      lcd_puts( @messages[i] || "" )
      i += 1
    end

    draw_contents()
    return nil
  end

  def draw_contents()
    s = "     NO    YES"
    case @select
    when :YES; s[10] = ">"
    when :NO;  s[4] = ">"
    end
    lcd_location( 3, 0 )
    lcd_puts( s )
  end

  def action( ev )
    case ev
    when :LEFT;   @select = :NO
    when :RIGHT;  @select = :YES
    when :OK;     @selected = @select; return :GOBACK
    when :CANCEL;                      return :GOBACK
    end

    draw_contents()
    return nil
  end
end


##
# スライダー
#
class MenuSlider < Menu
  attr_reader :value
  attr_reader :commit

  def initialize(name, value = 0, min_value = 0, max_value = 100, step = 10)
    super(name)
    @value = value
    @min_value = min_value
    @max_value = max_value
    @step = step
  end

  def draw_contents()
    v = (@value - @min_value) * (LCD_COLUMN-2) / (@max_value - @min_value)

    lcd_location( 2, 0 )
    lcd_puts("[" + "=" * v + "_" * (LCD_COLUMN-2-v) + "]")
  end

  def action( ev )
    value = @value
    case ev
    when :LEFT
      @value -= @step

    when :RIGHT
      @value += @step

    when :OK, :CANCEL
      @commit = ev
      return :GOBACK
    end

    @value = @min_value if @value < @min_value
    @value = @max_value if @value > @max_value
    if value != @value
      draw_contents()
      value_changed()
    end
    return nil
  end

  def value_changed()
  end
end

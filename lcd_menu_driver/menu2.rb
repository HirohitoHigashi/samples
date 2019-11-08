# coding: utf-8
require_relative "./menu_test_mock"
require_relative "./menu_driver"

#
# サブメニューのテスト
#
root_menu = MenuSelector.new("TOP MENU")
root_menu.add_menu( Menu.new("submenu1") )
root_menu.add_menu( Menu.new("submenu2") )
root_menu.add_menu( Menu.new("submenu3") )
root_menu.add_menu( Menu.new("submenu4") )
root_menu.add_menu( Menu.new("submenu5") )
root_menu.add_menu( Menu.new("submenu6") )


menu = MenuDriver.new( root_menu )
while true
  menu.drive()
end

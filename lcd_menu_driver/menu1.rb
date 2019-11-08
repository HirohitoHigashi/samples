# coding: utf-8
require_relative "./menu_test_mock"
require_relative "./menu_driver"

#
# ルートメニューのみのテスト
#
root_menu = Menu.new("test menu")

menu = MenuDriver.new( root_menu )
while true
  menu.drive()
end

# coding: utf-8
require_relative "./menu_test_mock"
require_relative "./menu_driver"

#
# ダイアログ
#
msg1 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

root_menu = MenuDialog.new("dialog1", msg1)

menu = MenuDriver.new( root_menu )
while true
  menu.drive()
end

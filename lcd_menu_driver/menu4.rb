# coding: utf-8
require_relative "./menu_test_mock"
require_relative "./menu_driver"

#
# Confirmのテスト
#
root_menu = MenuConfirm.new("confirm", "Really quit?")
root_menu.selected = :NO

menu = MenuDriver.new( root_menu )
while true
  menu.drive()
  if root_menu.selected == :YES
    break
  end
end

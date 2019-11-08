# coding: utf-8
require_relative "./menu_test_mock"
require_relative "./menu_driver"

#
# sliderのテスト
#
root_menu = MenuSlider.new("Slider1")

menu = MenuDriver.new( root_menu )
while true
  menu.drive()
  p [root_menu.value, root_menu.commit]; sleep 0.5
end

# coding: utf-8
require_relative "./menu_test_mock"
require_relative "./menu_driver"

msg1 = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmodtempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eufugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."


root_menu = MenuSelector.new("TOP MENU")
root_menu.add_menu( Menu.new("Function 1"))
root_menu.add_menu( Menu.new("Function 2"))

sub_menu1 = MenuSelector.new("SUB MENU")
sub_menu1.add_menu( Menu.new("SubFunc 1"))
sub_menu1.add_menu( Menu.new("SubFunc 2"))
sub_menu1.add_menu( Menu.new("SubFunc 3"))
root_menu.add_menu( sub_menu1 )

root_menu.add_menu( MenuDialog.new("Dialog1", msg1))

confirm_quit = MenuConfirm.new("Confirm1", "Really quit?")
root_menu.add_menu( confirm_quit )


menu = MenuDriver.new( root_menu )
while true
  menu.drive()
  if confirm_quit.selected == :YES
    break
  end
end

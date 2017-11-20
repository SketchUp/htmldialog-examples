require 'step01.rb'
require 'step02.rb'
require 'step03.rb'
require 'step04.rb'
require 'step05.rb'
require 'step06.rb'
require 'step07.rb'

require 'sketchup.rb'

module Examples
module MaterialInspector
TUTORIALS = self
module TutorialController

  OSX = Sketchup.platform == :platform_osx

  def self.create_step(index, title, &block)
    cmd = UI::Command.new(title, &block)
    cmd.tooltip = title
    ext = OSX ? 'pdf' : 'svg'
    # https://www.flaticon.com/free-icons/numbers_931
    icon = File.join(__dir__, 'images', "#{index}.#{ext}")
    cmd.small_icon = icon
    cmd.large_icon = icon
    cmd
  end

  unless file_loaded?(__FILE__)
    step01 = self.create_step(1, 'Step 01') {
      TUTORIALS::Step01.show_dialog
    }

    step02 = self.create_step(2, 'Step 02') {
      TUTORIALS::Step02.show_dialog
    }

    step03 = self.create_step(3, 'Step 03') {
      TUTORIALS::Step03.show_dialog
    }

    step04 = self.create_step(4, 'Step 04') {
      TUTORIALS::Step04.show_dialog
    }

    step05 = self.create_step(5, 'Step 05') {
      TUTORIALS::Step05.show_dialog
    }

    step06 = self.create_step(6, 'Step 06') {
      TUTORIALS::Step06.show_dialog
    }

    step07 = self.create_step(7, 'Step 07') {
      TUTORIALS::Step07.show_dialog
    }

    toolbar = UI::Toolbar.new('HtmlDialog Examples')
    toolbar.add_item(step01)
    toolbar.add_item(step02)
    toolbar.add_item(step03)
    toolbar.add_item(step04)
    toolbar.add_item(step05)
    toolbar.add_item(step06)
    toolbar.add_item(step07)
    toolbar.restore
    file_loaded(__FILE__)
  end

end # TutorialController
end # MaterialInspector
end # Examples
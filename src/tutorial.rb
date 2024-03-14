require_relative 'step01.rb'
require_relative 'step02.rb'
require_relative 'step03.rb'
require_relative 'step04.rb'
require_relative 'step05.rb'
require_relative 'step06.rb'
require_relative 'step07.rb'

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
    step01 = self.create_step(1, 'Step 01 - Basic Usage') {
      TUTORIALS::Step01.show_dialog
    }

    step02 = self.create_step(2, 'Step 02 - (Partially) Reusable window') {
      TUTORIALS::Step02.show_dialog
    }

    step03 = self.create_step(3, 'Step 03 - (Fully) Reusable Window') {
      TUTORIALS::Step03.show_dialog
    }

    step04 = self.create_step(4, 'Step 04 - Adding JS Framework') {
      TUTORIALS::Step04.show_dialog
    }

    step05 = self.create_step(5, 'Step 05 - Realistic Example') {
      TUTORIALS::Step05.show_dialog
    }

    step06 = self.create_step(6, 'Step 06 - Adding UI Framework') {
      TUTORIALS::Step06.show_dialog
    }

    step07 = self.create_step(7, 'Step 07 - Tuning UI') {
      TUTORIALS::Step07.show_dialog
    }

    step08 = self.create_step(8, 'Step 08 - Prototype') {
      TUTORIALS::Step08.show_dialog
    }

    toolbar = UI::Toolbar.new('HtmlDialog Examples')
    toolbar.add_item(step01)
    toolbar.add_item(step02)
    toolbar.add_item(step03)
    toolbar.add_separator
    toolbar.add_item(step04)
    toolbar.add_item(step05)
    toolbar.add_separator
    toolbar.add_item(step06)
    toolbar.add_item(step07)
    toolbar.add_separator
    toolbar.add_item(step08)
    toolbar.restore
    file_loaded(__FILE__)
  end

end # TutorialController
end # MaterialInspector
end # Examples
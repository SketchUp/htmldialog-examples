module Examples
module MaterialInspector
module Step04

  # Using Vue to bind data.
  # Multiple callbacks from JS is safe.

  def self.create_dialog
    html_file = File.join(__dir__, 'html', 'step04.html') # Use external HTML
    options = {
      :dialog_title => "Material",
      :preferences_key => "example.htmldialog.materialinspector",
      :style => UI::HtmlDialog::STYLE_DIALOG
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.set_file(html_file) # Can be set here.
    dialog.center
    dialog
  end

  def self.show_dialog
    if @dialog && @dialog.visible?
      @dialog.bring_to_front
    else
      @dialog ||= self.create_dialog
      @dialog.add_action_callback('poke') { |action_context, name, num_pokes|
        self.on_poke(name, num_pokes)
        nil
      }
      @dialog.add_action_callback('say') { |action_context, string|
        puts string
        nil
      }
      @dialog.show
    end
  end

  def self.on_poke(name, num_pokes)
    puts 'Get ready...'
    num_pokes.times {
      puts "Poke #{name}!"
    }
    # More pokes next time!
    @dialog.execute_script("app.num_pokes = #{num_pokes + 1}")
    # Switch target - muhahaha!
    target = %w[Thom Chris Jin Jeremy].sample
    @dialog.execute_script("app.name = '#{target}'")
  end

end # Step04
end # MaterialInspector
end # Examples

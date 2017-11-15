module Examples
module MaterialInspector
module Step01

  # Basic Hello World.
  # Creates new window every time.

  def self.show_dialog
    html = <<-EOT
    <h1>Hello World<h1>
    <p><button onclick="sketchup.poke('Thom', 3)">Poke</button></p>
EOT
    options = {
      :dialog_title => "Material",
      :preferences_key => "example.htmldialog.materialinspector",
      :style => UI::HtmlDialog::STYLE_DIALOG  # New feature!
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.set_html(html)
    dialog.center # New feature!
    dialog.add_action_callback('poke') { |action_context, name, num_pokes|
      # New feature: callback parameters support basic types.
      self.on_poke(name, num_pokes) # Delegate to method for easier debugging.
      nil
    }
    dialog
    dialog.show
  end

  def self.on_poke(name, num_pokes)
    num_pokes.times {
      puts "Poke #{name}!"
    }
  end

end # Step01
end # MaterialInspector
end # Examples

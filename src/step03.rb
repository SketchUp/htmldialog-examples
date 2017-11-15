module Examples
module MaterialInspector
module Step03

  # Window fully reusable.

  def self.create_dialog
    options = {
      :dialog_title => "Material",
      :preferences_key => "example.htmldialog.materialinspector",
      :style => UI::HtmlDialog::STYLE_DIALOG
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.center
    dialog
  end

  def self.show_dialog
    if @dialog && @dialog.visible?
      @dialog.bring_to_front
    else
      html = <<-EOT
        <h1>Hello World<h1>
        <p><button onclick="sketchup.poke('Thom', 3)">Poke</button></p>
      EOT
      @dialog ||= self.create_dialog
      @dialog.add_action_callback('poke') { |action_context, name, num_pokes|
        self.on_poke(name, num_pokes)
        nil
      }
      @dialog.set_html(html)
      @dialog.show
    end
  end

  def self.on_poke(name, num_pokes)
    num_pokes.times {
      puts "Poke #{name}!"
    }
  end

end # Step03
end # MaterialInspector
end # Examples
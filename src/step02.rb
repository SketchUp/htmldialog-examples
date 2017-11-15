module Examples
module MaterialInspector
module Step02

  # Reuse window, bring to front if already visible.
  # However, html and action callbacks not reusable.

  def self.create_dialog
    html = <<-EOT
    <h1>Hello World<h1>
    <p><button onclick="sketchup.poke('Thom', 3)">Poke</button></p>
EOT
    options = {
      :dialog_title => "Material",
      :preferences_key => "example.htmldialog.materialinspector",
      :style => UI::HtmlDialog::STYLE_DIALOG
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.set_html(html)
    dialog.center
    dialog.add_action_callback('poke') { |action_context, name, num_pokes|
      self.on_poke(name, num_pokes)
      nil
    }
    dialog
  end

  def self.show_dialog
    @dialog ||= self.create_dialog
    @dialog.visible? ? @dialog.bring_to_front : @dialog.show
  end

  def self.on_poke(name, num_pokes)
    num_pokes.times {
      puts "Poke #{name}!"
    }
  end

end # Step02
end # MaterialInspector
end # Examples
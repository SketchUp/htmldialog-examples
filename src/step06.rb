require 'sketchup.rb'
require 'json'

module Examples
module MaterialInspector
module Step06

  # Adding UI frameworks for some style.

  def self.create_dialog
    html_file = File.join(__dir__, 'html', 'step06.html')
    options = {
      :dialog_title => "Material",
      :preferences_key => "example.htmldialog.materialinspector",
      :style => UI::HtmlDialog::STYLE_DIALOG
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.set_file(html_file)
    dialog.center
    dialog
  end

  def self.show_dialog
    @dialog ||= self.create_dialog
    @dialog.add_action_callback("ready") { |action_context|
      self.update_dialog
      nil
    }
    @dialog.add_action_callback("accept") { |action_context, value|
      self.update_material(value)
      @dialog.close
      nil
    }
    @dialog.add_action_callback("cancel") { |action_context, value|
      @dialog.close
      nil
    }
    @dialog.add_action_callback("save") { |action_context, value|
      self.update_material(value)
      nil
    }
    @dialog.show
  end

  # Populate dialog with selected material.

  def self.update_dialog
    return if @dialog.nil?
    material_data = nil
    model = Sketchup.active_model
    if model.selection.size == 1
      material = self.selected_material
      material_data = self.material_to_hash(material) if material
    end
    json = material_data ? JSON.pretty_generate(material_data) : 'null'
    @dialog.execute_script("updateMaterial(#{json})")
  end

  # Edit a material.

  def self.update_material(data)
    model = Sketchup.active_model
    material = model.materials[data['name']]
    r = data['color']['red']
    g = data['color']['green']
    b = data['color']['blue']
    color = Sketchup::Color.new(r, g, b)
    model.start_operation('Edit Material')
    material.color = color
    material.alpha = data['alpha']
    material.colorize_type = data['colorize_type']
    model.commit_operation
  end

  # Observer handling.

  def self.on_selection_change(selection)
    self.update_dialog
  end

  def self.on_material_change(material)
    if material == self.selected_material
      self.update_dialog
    end
  end

  # Collect model data.

  def self.selected_material
    material = nil
    model = Sketchup.active_model
    if model.selection.size == 1
      material = nil
      entity = model.selection.first
      if entity.respond_to?(:material) && entity.material
        material = entity.material
      elsif entity.respond_to?(:back_material)
        material = entity.back_material
      end
    end
    material
  end

  # Convert objects to Hashes.

  def self.material_to_hash(material)
    return nil if material.nil?
    {
      name: material.name,
      display_name: material.display_name,
      type: material.materialType,
      color: self.color_to_hash(material.color),
      alpha: material.alpha,
      texture: self.texture_to_hash(material.texture),
      colorize_type: material.colorize_type,
      colorize_deltas: material.colorize_deltas,
    }
  end

  def self.color_to_hash(color)
    {
      red: color.red,
      green: color.green,
      blue: color.blue,
      alpha: color.alpha,
    }
  end

  def self.texture_to_hash(texture)
    return nil if texture.nil?
    {
      filename: texture.filename,
      pixel_width: texture.image_width,
      pixel_height: texture.image_height,
      model_width: texture.width,
      model_height: texture.height,
      model_width_formatted: texture.width.to_l.to_s,
      model_height_formatted: texture.height.to_l.to_s,
      average_color: self.color_to_hash(texture.average_color)
    }
  end

  # Observe selected material.

  PLUGIN = self
  class SelectionChangeObserver < Sketchup::SelectionObserver
    def onSelectionAdded(selection, entity)
      PLUGIN.on_selection_change(selection)
    end
    def onSelectionBulkChange(selection)
      PLUGIN.on_selection_change(selection)
    end
    def onSelectionCleared(selection)
      PLUGIN.on_selection_change(selection)
    end
    def onSelectionRemoved(selection, entity)
      PLUGIN.on_selection_change(selection)
    end
    def onSelectedRemoved(selection, entity)
      PLUGIN.on_selection_change(selection)
    end
  end

  class MaterialChangeObserver < Sketchup::MaterialsObserver
    def onMaterialChange(materials, material)
      PLUGIN.on_material_change(material)
    end
    def onMaterialRemove(materials, material)
      PLUGIN.on_material_change(material)
    end
  end

  class AppObserver < Sketchup::AppObserver
    def onNewModel(model)
      observe_model(model)
    end
    def onOpenModel(model)
      observe_model(model)
    end
    def expectsStartupModelNotifications
      return true
    end
    private
    def observe_model(model)
      model.selection.add_observer(SelectionChangeObserver.new)
      model.materials.add_observer(MaterialChangeObserver.new)
    end
  end

  unless file_loaded?(__FILE__)
    Sketchup.add_observer(AppObserver.new)
  end

  file_loaded(__FILE__)

end # Step06
end # MaterialInspector
end # Examples

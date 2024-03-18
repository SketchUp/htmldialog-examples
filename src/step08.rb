require 'sketchup.rb'
require 'json'
require 'fileutils'
require 'rexml/document'
require 'rexml/xpath'

# load 'C:/Users/tthomas2/SourceTree/htmldialog-examples/src/step08.rb'
module Examples
module MaterialInspector
module Step08

  # Fine tuning UI.

  def self.create_dialog
    html_file = File.join(__dir__, 'html', 'step08.html')
    options = {
      :dialog_title => "Material",
      :preferences_key => "com.sketchup.example.htmldialog.pbrbrowser",
      :style => UI::HtmlDialog::STYLE_DIALOG,
      :resizable => true,
      :width => 800,
      :height => 600,
    }
    dialog = UI::HtmlDialog.new(options)
    dialog.set_file(html_file)
    dialog.center
    dialog
  end

  # @param [Hash]
  def self.get_materials(uri)
    @request = Sketchup::Http::Request.new(uri, Sketchup::Http::GET)
    @request.start do |request, response|
      puts "Response: #{response.status_code}"
      # puts "body: #{response.body}"
      data = response.body
      self.update_materials(data)
    end
    nil
  end

  # @param [String] data
  # @return [Hash]
  def self.update_materials(data)
    materials = self.parse_materials(data)
    # puts JSON.pretty_generate(materials)
    json = JSON.pretty_generate(materials)
    @dialog.execute_script("updateMaterials(#{json})")
  end

  # @param [String] data
  # @return [Hash]
  def self.parse_materials(data)
    # doc = REXML::Document.new(data)
    assets_regex = /<div\s+class="AssetBox"\s+title="([^"]+)">(.*?)<\/a>\s*<\/div>/m
    # asset_regex = /<a\s+href="([^"]+)">.*?<img\s+.*src="([^"]+)"/m
    asset_regex = /<a\s+href="([^"]+)">.*?<img.*?<img\s+.*src="([^"]+)"/m

    result = []
    assets_data = data.scan(assets_regex)
    assets_data.each { |title_attr, asset_data|
      # p asset_data.size
      title = title_attr.lines.first.strip
      title = title[title.index(' ')...].strip # strip away emoji prefix
      # puts title
      # puts asset_data
      matches = asset_data.scan(asset_regex)
      uri, thumb_uri = matches[0]
      # puts uri
      # puts thumb_uri

      result << {
        title: title,
        uri: uri,
        thumb_uri: thumb_uri,
      }
      # break
    }
    result
  end

  # @param [Hash] material_data
  def self.fetch_download_data(material_data)
    puts "Fetch download data: #{material_data['title']}"
    base = 'https://ambientcg.com'
    uri = "#{base}#{material_data['uri']}"
    @download_data_request = Sketchup::Http::Request.new(uri, Sketchup::Http::GET)
    @download_data_request.start do |request, response|
      puts "Response: #{response.status_code}"
      self.parse_download_data(response, material_data)
    end
    nil
  end

  # @param [Sketchup::HTTP::Response] response
  # @param [Hash] material_data
  def self.parse_download_data(response, material_data)
    data = response.body
    # TODO: Multiple downloads available.
    download_regex = /<div\s+class='DownloadButtons'>\s*<a\s+.*?\s+href="([^"]+)"/m
    download_uri = data.scan(download_regex).first.first
    p download_uri
    material_data['download_uri'] = download_uri
    self.download_material(material_data)
    nil
  end

  # @param [Hash] material_data
  def self.download_material(material_data)
    puts "Downloading material: #{material_data['title']}"
    uri = material_data['download_uri']
    p uri
    @download_request = Sketchup::Http::Request.new(uri, Sketchup::Http::GET)
    @download_request.start do |request, response|
      puts "Response: #{response.status_code}"
      self.load_material(response, material_data)
    end
    nil
  end

  # @param [Sketchup::HTTP::Response] response
  # @param [Hash] material_data
  def self.load_material(response, material_data)
    data = response.body
    temp_path = File.join(Sketchup.temp_dir, 'su-pbr.zip')
    puts temp_path
    File.binwrite(temp_path, data)
    self.extract_pbr_zip(temp_path, material_data)
    nil
  end

  # @param [String] temp_path
  # @param [Hash] material_data
  def self.extract_pbr_zip(temp_path, material_data)
    puts "Extracting PBR ZIP: #{temp_path}"

    # puts temp_path
    # p material_data
    out_path = File.join(Sketchup.temp_dir, 'su-pbr')
    if File.exist?(out_path)
      puts 'Cleaning out old temp dir...'
      FileUtils.rm_r(out_path)
    end
    FileUtils.mkdir_p(out_path)
    puts %{tar -xf "#{temp_path}" -C "#{out_path}"}
    `tar -xf "#{temp_path}" -C "#{out_path}"`
    puts "Output dir exists: #{File.exist?(out_path)} (#{out_path})"

    pattern = File.join(out_path, '*.mtlx')
    mtlx_path = Dir.glob(pattern).to_a.first
    mtlx_data = File.read(mtlx_path)
    doc = REXML::Document.new(mtlx_data)

    base_path = nil
    metallness_path = nil
    roughness_path = nil
    normal_path = nil
    ao_path = nil

    REXML::XPath.each(doc, "/materialx/standard_surface/input") { |node|

      if node['name'] == 'base_color'
        node_name = node['nodename']
        REXML::XPath.each(doc, "/materialx/tiledimage") { |n|
          next unless n['name'] == node_name

          REXML::XPath.each(n, "input") { |input|
            next unless input['type'] == 'filename'

            base_path = File.join(out_path, input['value'])
          }
        }
      end

      # TODO: Correct to assign this to metalness?
      if node['name'] == 'specular_roughness'
        node_name = node['nodename']
        REXML::XPath.each(doc, "/materialx/tiledimage") { |n|
          next unless n['name'] == node_name

          REXML::XPath.each(n, "input") { |input|
            next unless input['type'] == 'filename'

            metallness_path = File.join(out_path, input['value'])
          }
        }
      end

      if node['name'] == 'coat_roughness'
        node_name = node['nodename']
        REXML::XPath.each(doc, "/materialx/tiledimage") { |n|
          next unless n['name'] == node_name

          REXML::XPath.each(n, "input") { |input|
            next unless input['type'] == 'filename'

            roughness_path = File.join(out_path, input['value'])
          }
        }
      end

      if node['name'] == 'normal'
        node_name = node['nodename']
        # p node
        # p node_name
        REXML::XPath.each(doc, "/materialx/normalmap") { |n|
          next unless n['name'] == node_name

          REXML::XPath.each(n, "input") { |input|
            normal_node_name = input['nodename']
            next unless normal_node_name

            # p normal_node_name
            REXML::XPath.each(doc, "/materialx/tiledimage") { |n|
              next unless n['name'] == normal_node_name

              REXML::XPath.each(n, "input") { |input|
                next unless input['type'] == 'filename'

                normal_path = File.join(out_path, input['value'])
              }
            }
          }
        }
      end
    }

    ao_temp_path = base_path.sub('_Color.', '_AmbientOcclusion.')
    ao_path = ao_temp_path if File.exist?(ao_temp_path)

    [base_path, roughness_path, normal_path, ao_path].each { |path|
      p [path ? File.exist?(path): nil, path]
    }

    image_rep = Sketchup::ImageRep.new(base_path)
    w = image_rep.width
    h = image_rep.height
    image_rep.set_data(1, 1, 8, 0, "\0")

    r = h.to_f / w.to_f
    mw = 1.m
    mh = mw * r

    model = Sketchup.active_model
    model.start_operation('Load PBR Material', true)
    material = model.materials.add(name)
    material.texture = [base_path, mw, mh]
    material.roughness_texture = roughness_path if roughness_path && File.exist?(roughness_path)
    material.normal_texture = normal_path if normal_path && File.exist?(normal_path)
    material.ao_texture = ao_path if ao_path && File.exist?(ao_path)
    model.commit_operation

    nil
  end

  # Examples::MaterialInspector::Step08.extract_debug
  def self.extract_debug
    path = 'C:/Users/tthomas2/AppData/Local/Temp/su-pbr.zip'
    data = {
      "thumb_uri"=>"https://acg-media.struffelproductions.com/file/ambientCG-Web/media/thumbnail/256-JPG-242424/PavingStones138.jpg",
      "title"=>"Paving Stones 138",
      "uri"=>"/view?id=PavingStones138",
      "download_uri"=>"https://ambientcg.com/get?file=PavingStones138_1K-JPG.zip"
    }
    self.extract_pbr_zip(path, data)
    nil
  end

  def self.show_dialog
    # @dialog ||= self.create_dialog
    @dialog = self.create_dialog
    @dialog.add_action_callback("ready") {
      self.update_dialog
      nil
    }
    @dialog.add_action_callback("accept") { |_, value|
      # self.update_material(value)
      @dialog.close
      nil
    }
    @dialog.add_action_callback("cancel") { |_, value|
      @dialog.close
      nil
    }
    @dialog.add_action_callback("download") { |_, value|
      p value
      self.fetch_download_data(value)
      nil
    }
    @dialog.show
  end

  # Populate dialog with selected material.

  def self.update_dialog
    return if @dialog.nil?

    uri = 'https://ambientcg.com/list?category=&date=&createdUsing=&basedOn=&q=&method=&type=Material&sort=Popular'
    self.get_materials(uri)

    # material_data = nil
    # model = Sketchup.active_model
    # if model.selection.size == 1
    #   material = self.selected_material
    #   if material
    #     material_data = self.material_to_hash(material)
    #     # Write out a material thumbnail.
    #     self.generate_texture_preview(material)
    #   end
    # end
    # json = material_data ? JSON.pretty_generate(material_data) : 'null'
    # @dialog.execute_script("updateMaterial(#{json})")
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

  def self.generate_texture_preview(material)
    return unless material && material.texture
    preview_file = File.join(__dir__, 'images', 'preview.png')
    unless material.write_thumbnail(preview_file, 128)
      # .write_thumbnail fails can fail if dimensions are equal or smaller than
      # the actual size of the textures.
      material.texture.write(preview_file)
    end
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
    # Sketchup.add_observer(AppObserver.new)
  end

  file_loaded(__FILE__)

end # Step08
end # MaterialInspector
end # Examples

# `UI::HtmlDialog` Examples

These examples were originally presented at SketchUp DevCamp 2017 in Leeds, UK.

They have later been updated and tweaked.

The examples are grouped into three parts:
* [HtmlDialog class](#part-1-htmldialog-class) (key difference from WebDialog).
* [Communication between Ruby and JS.](#part-2-communication-between-ruby-and-js) HTML content synchronization.
* [Styling.](#part-3-styling)

![](Screenshot.png)

Below are some of the notes for each example:

## Part 1: HtmlDialog Class

### Example 1

* `UI::HtmlDialog` added in SU2017.
* Key benefit is predictable web-engine.
*   Same Chromium version across platform for each SketchUp version.
* Basic "Hello World".
* Many similar methods from `UI::WebDialog`.
* Some difference in behaviour.
* Some extra visual options.
* Bye skp actions - hello `sketchup` object.
* `get_element_value` is gone - due to Chromium async nature.

### Example 2

* Typical window behaviour - reuse window.
* Bring to front if already visible.
* Note: Different from WebDialog, html and action callbacks doesn't work reused.
* Reason is related to Chromium being in another process. Keeping
  the registered callbacks turned difficult.

### Example 3

* Another pattern for reusing window.
* Register callbacks before showing dialog. Every time.
* If using `set_html`, also do that before showing dialog.

## Part 2: Communication between Ruby and JS.

### Example 4

* Syncing data with Ruby, JS and HTML.
* Use frameworks like Vue, React, etc. to bind data.
* Avoids DOM handling.
* Vue is just one of many frameworks, React etc is similar.
* In the template we can display data using `{{ }}`. When the data updates the
  HTML updates automatically.
* For form elements use `v-model` or `v-bind` to bind data properties to the
  template. User interactions is synchronized back to `data`.
* Notice `say_something` make consecutive callbacks and aren't lost as oppose to the old skp-actions.

### Example 5

* Lets create something more realistic.
* Material edit dialog.
* Select entity, display material.
* Pushing data to dialog when it's ready...
  * With Vue, use the `mounted` event.
  * With jQuery, use the `ready` callback.
  * When Ruby get `ready` callback, push data back to dialog.
* We push data by calling JavaScript functions.
* Recommend using JSON for object structures.
* `self.material_to_hash` convert `Sketchup::Material` to a hash with its properties.
* `v-if` conditionally control what to display based on data.
* Opacity is special - data from API is 0.0-1.0, UI use 0-100.
* Computed properties can be used for custom display of data.

## Part 3: Styling

### Example 6

* Styling webdialogs.
* Look at UI frameworks; Bootstrap, Trimble Modus.
* Add reference to Trimble Modus CSS and JS libs.
* Few Ruby change, we mostly add some HTML classes to our elements.

### Example 7

* Tweaking layout.
* Using grid system - two eight wide columns (in 16 columns max).
* Some manual CSS adjustments.
* Some padding around content.
* Positioning the footer at the bottom.
* Adjusting the input widths.
* Custom element for color and texture preview.

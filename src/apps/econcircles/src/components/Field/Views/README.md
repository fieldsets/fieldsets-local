# Field Types
Field Types represent the input data types, validation and default visualization for fields.

* Default - uses text as the default.
* Text - A standard text input.
* Editor - A multi line text editor such as a WYSIWYG or Markup Editor.
* Numeric - A standard text input with numeric validation.
* Hidden - Used for forms and tracking static data that might be set in code. No validation.
* Select - A single select drop down that you can pass valid string options. No validation.
* Date - a datepicker field.
* Function - Non-editable value that is calculated off a subset of fields. Functions can be defined in (Functions.js)[../Functions.js]

Custom FieldTypes can be defined in `components/Fields`

If you'd like to override the render view for a field type but pass them through the same validators, you can use the `view` prop for the `Field` component to define it in the `components/Fields` directory.

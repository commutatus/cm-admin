This config file breaks down the index page into *configurable* entity with different parts acting *modular* and independently configurable. 4 parts are descibed here *filters*, *table*, *form*, *export*. These 4 parts have been broken down into blocks of configuration which get executed independently.

**field names are indicative of the function they serve on [this particular design](https://www.figma.com/file/4VGtOxC8k0EDCRtukAgF3E/Admin-panel?node-id=1218%3A59).*<br>
**field values are indicative.*
***

### Filters

```
name: #{filter_name}
placeholder: #filter input box placeholder
scope: #{scope_name}
type: [:select/ :multiselect/ :checkbox/ :number/ :string/ :checkbox/ :date/ :daterange, :datetimerange]
format: #input format for date types
options: #for select and multiselect type, default: []
onscreen: true/false
```

### Table (index)

Proposed ideas here - 
1. Have a block for each data element. 
```
header: #{header_name}
type: [:string, :date, :datetime, :integer, :float, :link, :tag, :range]
block_html: #html code for tag type
value: #{table_data_value}
url: #url for link type, default: #
css_class: #any additional css class for non tag type
format: #display format for date types
locked: true/false
min: #min value for range
max: #max value for range
```
caveats: long config file size, redundant expressions.

2. Have an array whose indices indicate a data attribute and all data elements follow that order as a syntax.
```
reference_array = [header, type, block_html, value, url, css_class, format, locked, min, max]
data_element_1 =  [Name, String, nil, full_name, nil, nam, nil, true, nil, nil]
```
caveats: invites devs to make mistakes because of the need to follow an order.
plus point: reference array can also be made custom. 

### Forms

```
instance_name: #{@instance_name}
input_field: #{input_field}
input_type: (options: [select, multi_select, single_select, number, text, checkbox, date, date_range, radio_button])
label: #{label}
placeholder: #{placeholder}
error_message: #{error_message}
error_message_class: #{error_message_class}
hint: #{hint}
```

### Exports

```
file_format: [csv, xml]
model: #{model name} (example: User)
headers_array: [name, age, email, phone, total orders]
row_values: [full_name, age, email, phone, orders.count]

```

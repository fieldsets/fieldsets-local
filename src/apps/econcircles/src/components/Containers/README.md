# Containers
Containers should be thought of as collections of FieldSets, each representing a data container for a single visualization.

# TODO: Container types

* Charts (d3 and others)
* Layouts (draggable context boxes)
* Editors (defining non numeric field values)
* Worksheet (excel like tables)

# TODO: Coordinate system.
Add in coordinate system that can exists outside of SVG defined viewbox. Allow us to use SVGs for creation of containers that allow for data input, but use Canvas for visual only rendering.



# Controller
The controller is used to manage swapping between containers. It tracks each container and it's last state in a top level Apollo local persistent cache fragment. You render your own controller view. By default, the controller does not provide an interface to switch between containers. You can specify an interface by wrapping all of your containers/interfaces in an interface component.

# Interface
An interface is a specialized container that overlays a data container such as a Diagram or Layout. It will never command the container Focus or have it's data stored in the container query of the cache.

The interface instead stores data that is specific to interactions with a given data container or set of containers ( filter options, UI choices, menu options, user accounts, search etc). An interface allows a user to change the way FieldSets are displayed and visualized.

A more technical explanation is that Interfaces use a single Controller context component between them to decide what should be displayed. Like standard Containers, each Interface is also assigned it's own context are each assigned their own context that all child components can access.

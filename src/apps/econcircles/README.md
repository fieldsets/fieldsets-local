# Visual Fieldsets
Visual Fieldsets is the data visualization component of the Fieldsets Full Stack Framework. It is written in React and is used to help develop data visualization applications, allowing for greater flexibilty around what 3rd party visualization software is used. This app is agnostic to whether you use SVG, HTML5, Canvas or any frameworks around core visualization approaches to the modern browser.

Visual Fieldsets is both a UI and a data abstraction layer. It will provide you [Material Design Components](https://react-md.mlaursen.com/) to wrap around your data visualization diagram as well as a flexible abstract data layer which can be pulled into any data visualization framework of your choice. Originally funded by [Econ Circles](https://www.econcircles.com), this framework was built to be able to quickly generate a diverse set of data visualizations for non standardized data sets and sources.

# Default Example
As our proof of concept, we will draw a circle diagram that can render a visualization for how to best invest in the future. It is used as a sales tool and is used to help clients see how their income and savings are grouped and determine the best path forward with any additional resources.

In this example, we rely on strict SVG standards when rendering our node in browser, but you could simply pass a SVG instead via d3, or simply use css and html5. As this a work in progress, many of these truths have not been tested as functional, let alone paid attention to. Most likely there are a bunch of place holders for the `@TODO: $DREAMING_BIG` thoughts.


# Technical Components

Econ Circles is built using react and material design as the primary framework for the UI and d3/svg for the data visualization. On the backend, the application uses apollo/graphQL for both local state storage as well as remote data queries. This application is built using Google Sheets as a data store, but allows for the flexibility to swap data stores easily to a more traditional database approach. Google sheets is a familiar tool for many financial planners so it allows us to get the application running quickly without the need for doing heavy data architecture design.

## System Requirements

* [NPM](https://www.npmjs.com/get-npm) (Built with 6.4.1)

# Getting Started

From the local top level directory of this codebase run:
``npm install``

For local development and to run a server locally run:
``npm run start``

For a final production build:

``npm run build``

# Code Structure

### Glossary

+ **UI**: The containers and components that a user interacts with. This does not include the data visualzation diagram.
+ **Diagram**: A SVG standards based data visualization that is displayed in the viewer aread of the UI
+ **Node**: (@TODO: Change name to Set) A grouping of data values
+ **Field**: A single data point which can be a static value or the product of a callback function.
+ **Account**: A heirarchical owner of a field.

## React-MD and UI
The UI components are pulled heavily from [react-md](https://react-md.mlaursen.com/components/autocompletes). The top level container for the UI can be found in `src/containers/UI` and you can trace down the corresponding components in the `src/components` directory.

## Data visualization Diagrams
The main set of data for the circles can be found in `src/data/Diagrams/CircleDiagram/DiagramData.js`. Currently it has labels, slugs and center locations for the parent child nodes of the diagram.

The main REACT component container for the data visualization is found in `src/containers/Diagrams/Diagrams/CircleDiagram/CircleDiagram.jsx` with the heavy lifting of SVG interactions and Transitions happening in `src/components/Sets/Set.jsx`.

## Styles

This App separates styles from react components so it does not require much knowledge to apply basic styles to the application. All styles are found in `src/styles` as scss and will be converted to css during the watch and build process. You may add any new scss files you like, just ensure you add file to the index of it's parent directory.

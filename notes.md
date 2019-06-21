
# Task

> As a next question in our conversation, I would like you to think about
> how you could contribute.
> 
> This file contains the sequence of operations that are executed when
> performing a simple copy-paste
> https://raw.githubusercontent.com/castor-software/code-strata/master/code-strata-2019/data/data.json
> the source code for the text editor is here
> https://github.com/castor-software/code-strata/tree/master/subjects/simple-file-editor
> 
> What kind of sonification would you propose to reveal one aspect of this
> specific program execution?
> 
> The task is deliberately very open because this is how research works.
> In case of problems (and there will be some), don't hesitate to make
> simplifying assumptions in order to achieve something meaningful.
> Then, I ask you to write a short document explaining the outcome of this
> task and your reflection on it. If you're not successful, you can
> reflect about the main difficulties you faced.

# Ideas

## Structures in common words

Go through the json and count occurences of words. Base sonification on where these words pop up.

## Structure in layers

Base kind of sound on how far down the tree an entry is so that the distance to the user can be heard.


## What kind of sounds would I want to use?

- Fast progression of short sounds to invoke the speed with which things are happening while keeping it on a human timescale?

# Documentation

## Simple file editor
Installed Netbeans to compile and run simple-file-editor in order to get a feel for the program.

The code seems incompatible with JavaFX 11. I get error messages about BehaviorSkinBase. It seems like I should use an older version of the JDK where JavaFX was built in, but downgrading is not straight forward.

## The JSON file

The structure of the JSON file seems to be that if a function A calls another function B, then B is a child node of A.

I don't really understand why the first node of the tree is "Main.SimpleTextEditor.lambda$onCloseEvent$0(javafx.stage.WindowEvent)". That seems to me like an event to close the program, not to copy or paste. There is no reference to copying or pasting that I've been able to find in the node tree. I will not worry too much about this, but instead deal with the data as it is.

### Analysis

By splitting the function names at . ( ) $ , I counted how many times each word occurred. There are 720 words in total and javafx is by far the most common one. In 9918 function calls it appeared 13111 times, on average 1.32 times per function call.

I decided to write the data in a different format, using '>' to denote how far down the tree a function is called and ending with the number of child nodes it has. This reveales a flowing pattern going down and up the call tree. I decided to print only the '>'s to emphasize the flowing pattern (saved as data_restyled_wave.txt).

#### Common words and their meaning

- **javafx**: The GUI library used.
- **scene**: The JavaFX Scene class is the container for all content in a scene graph.
- **beans**: The package javafx.beans contains the interfaces that define the most generic form of observability. All other classes in the JavaFX library, that are observable, extend the Observable interface. An implementation of Observable may support lazy evaluation. Implementations of Observable should strive to generate as few events as possible to avoid wasting too much time in event handlers.
- **Node**: Each item in the scene graph is called a Node. Leaf nodes are classes such as Rectangle, Text, ImageView, MediaView, or other such leaf classes which cannot have children.
- **property**: Appears mostly(?) in the form of "javafx.beans.property"
- **css**: Appears mostly as "javafx.css" or "com.sun.javafx.css" followed by e.g. StyleMap, Styleable, CalculatedValue, ParsedValueImpl, CascadingStyle
- **<init>**: Represents initialisation made in the constructor in a stacktrace. <init>() or <init>(Object) mostly, but also more elaborate initialisations.
- **layout**: javafx.scene.layout. Layouts are the top level container classes that define the UI styles for scene graph objects. Layout can be seen as the parent node to all the other nodes. JavaFX provides various layout panes that support different styles of layouts.
- **get**: Getter method



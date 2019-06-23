
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

#### Depth

The amount of functions per depth level follows some kind of normal distribution centered on depth level 22 out of 44 levels in total. These results are saved in depth_wave.txt and a screenshot in depth_wave.png.

#### Source

There are 14 entries with the source "App", the rest are from "javafx".

#### Words having something to do with copy-paste

- text: 453
- binding: 452
- Text: 418
- access: 229
- KeyHandler: 9
- KeyCodeCombination: 3
- getKeyHandler: 2
- KeyCombination: 2

These are the words I found which possibly have something closer to do with the copy paste. Many of the instances surely do not, for example the setup of the text area which seems to account for many of the instances of "text".

## Sonification

Different ways to use the data in sonification:

- as input to a wavetable oscillator
- the depth level of a function to indicate distance from the user
- the kinds of words included in the function name to signify different functionality
  - source App or javafx can have fundamentally different sounds
  - words to do with keys can have a fundamentally different sound

In terms of time scale, the easiest way would be to have a constant grid during which sound events are triggered. This makes the false assumption that every function takes the same amount of time to execute, but I have no way of knowing the execution time.

An important question is if functions shall "sound" only when they are first called or as long as they have child functions being executed. Having them sustain would mean that the first node will sound through the whole piece.

Should the child functions have something sonically to do with the function calling them, or be treated as independent? One such dependence would be to treat them as overtones to the first node (the only node at the first depth level).

### Sound material

The previous sonification of the same data used some kind of granular synthesis of the words copy paste so I will not use the same method.

The most straight forward and flexible way to sonify a dataset like this is through pure sound synthesis. The question is what parameters to focus on in conveying the structure of the data. 

Pitch implies its own structures which can be used to our advantage, either by using some part of tonal harmony, a spectral approach or perhaps polychords.

### Concrete implementation idea 1

Focusing on the aspect of things happening closer or further away from the user or even the programmer of the text editor.

Use the following sound mappings:

- reverb: depth level (how far away from the user)
- pitch: Different depending on the source. App entries take their pitch from a G major chord and javafx entries take theirs from a F#13 chord extending into overtones.
- amplitude: Higher depth value gives quieter notes, but certain words being present 
- length: Also depends on depth with higher depth values giving shorter notes
- timbre: Because a sine tone in a reverb and a long sine tone sound approximately the same, a different timbre with some random movement should be used. 
- tempo: Try keeping it constant, but it could also slow down at certain events and then speed up again.


# Experiments

Notes on the progression of experimental versions.

## copy-paste-1

All events are 0.01 s long (so it takes around 1:30 to play all events, but the last events ring out for a long time), but decay time is decided by depth level. Pitch is simply 50 * (depth_level + 1), so overtones of somewhere between G and G#. Decay time decreases exponentially by depth level making the first notes ring for a very long time. There are no reverb effects or similar, but the slope of the decay makes it sound kind of like there is.

The data has a structure that is much clearer when heard like this where the function calls are stuck at a very deep level for a long time until they slowly run back to the surface.

The triadic nature of the low overtones gives the piece quite a tonal closure ending on a stable tonic. The fact that the high overtones at deep levels are so close together makes the early middle part quite boring in my ears, and boring is (sometimes) the enemy of wonder.

## copy-paste-2

The only thing that changed here is the pitches of the events. App and javafx events take their pitches from different groups of notes, the first being a G major chord, the second a F#13 extended upwards some more. The depth level is wrapped at the size of the array making pitches suddenly jump going down the levels of depth. While this is less true to the structure of the data, it creates some rhythmic effects making the sonification more interesting. The actual depth level is also conveyed through other parameters like the decay time.

We lack the satisfying end of the tonic triad that kind of fits with the data, returning to the user to carry out the next task so to speak.

## copy-paste-3

Adds reverb, the amount of which depends on depth level. This gives the sounds a kind of under water feeling.

I experimented a little bit with letting the "relevance" level that I calculated using the words contained in the function, leaving most of my experiments out except for using it to modify the amplitude. This gives the sonification a bit more life.

I would like to have a greater difference between events of different depth levels. The closest sounds don't feel very close right now. This could perhaps be done using distortion or a different synthesis technique for certain sounds (plucked string?) that has more presence in its sound. This could also emphasise the G major chord that the piece ends with, which is very blurry right now.

## copy-paste-4

For this version I was experimenting with adding a wavetable synthesis based on the depth levels. I reduced the dataset by simply averaging points to create a wavetable of the correct size. As I thought, the result was a very high frequency heavy timbre. At fast attack rates it sounds like a plucked string under high tension. By overlaying the previous sound with this wavetable sound, but making it more implacted by the amplitude changes, more variation in timbre is produced.

Another change I made was to have panning be less and less extreme the further down in depth you go (to simulate things moving down towards the middle)

## copy-paste-5 

Increasing the duration of every event by a factor of 10 reveals a lot more detail about the structures inherent in the data. You can pick out some recurring motifs. It also makes the whole thing almost 17 minutes long.

The events are now at a rate that is playable by humans, although extremely difficult to perform exactly, so it is in within the normal timescale for music.

## copy-paste-6

Continuing the longer format. I changed the chord for the beginning and end (i.e. the source == "App" chord) to B which is the tonally simplest choice making the the whole thing one big cadence D13 - T. Reverb parameters and filters on the wavetable synthesis were tweaked.

I experimented with letting the event amplitude control duration, but that resulted in lots of long notes in a row which was boring and didn't sound very good. Having the tempo dynamically change based on note amplitude didn't work that well either.

While the piece is pretty long different parts of it are clearly different from eachother, there is a surprising amount of variation stemming from different combinations of depth levels and "relevance" metrics.
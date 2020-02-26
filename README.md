# Super Metroid Tools
A repository of Lua Code for the Bizhawk Emulator and Super Metroid.

# Installation
## You will need:
- The Bizhawk Emulator (http://tasvideos.org/BizHawk.html)
- The US/Japan Super Metroid Rom
- This script

## Installation
1. Install Bizhawk
2. Copy the script into BizHawkDir/Lua/SNES/SuperMetroid.lua (Note, it comes with Super Metroid.lua)
3. copy the ROM someplace that Bizhawk can find it
4. Open Bizhawk
5. Open the ROM file
6. Click *Tools* > *Lua Console*
7. In the Lua Console, *Script* > *Open Script*
8. Select the SuperMetroid.lua script
9. Start playing the game. You should see statistics on the screen.

# Explanation of the Lua Script
## Lines 3-11 
These lines were written by Pasky13, the person who wrote the default script that's included with Bizhawk. It sets up two global variables that track the current scaling factor. This is usually integer (1-4) however it could be decimal in the case of fullscreen views. 

## Lines 12-16
These are global variables that determine the text color and background color for the text as well as the position for the status panel.

## Lines 18-29
These lines define the data in the class that is used to create the panel at the bottom left of the screen. The variables inside will be passed to the appropriate functions for drawing the panel.

## Lines 31-38
Constructor for the BottomPanel class.

## Lines 40-42
This inserts a line of text onto the panel for rendering in the game window

## Lines 44-84
This function calculates the size and position of the bottom rectangle. Below in the subsections I describe each section of the function

### > Lines 45-50
Define all the variables needed for the function. boxHeight is how big the box should be vertically, while the gameWidth determines how wide the viewport is. biggestWidth determines the maximum width of the longest string in characters so that the box rendered is big enough for it. width is the width of the box in pixels as determined by biggestWidth. 

### > Lines 54-55
This calculates the game viewport size based on the viewport's height.

### > Lines 58-61
The box sizing is inclusive of the border, so it has to account for the border size if a border is specified.

### > Lines 63-64
Does the actual calculation for the height

### > Lines 66-69
Figures out the longest string and stores the number of characters in that string in biggestWidth

### > Line 71
Determines the actual width by multiplying the biggest width by the character width. It also addes the current width which may be more than 0 if there's a border.

### > Line 73
Stores the width in the object

### > Lines 75-77
Determines the offset needed to put the box on the bottom left hand corner of the game viewport as opposed to the window.

### > Lines 81-83
Assigns the offsets to the object and returns the pair of offsets.

## Lines 86-102
Renders the actual panel into the game viewport. Individual lines are described below:

# More to come! #
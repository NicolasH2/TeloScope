# Get FiJi and the BioVoxxel plug-in

- Download [FiJi](https://imagej.net/Fiji/Downloads) and start it
- Navigate to ´Help´-´Update´... (doing this the first time will take some time and you might need to restart; go again on Help-Update...)
- A window will open, click on the lower left [Manage update sites]
- Look for the [BioVoxxel](https://www.biovoxxel.de/) Toolbox, click on the box on its left to leave a checkmark, then click on ´Close´
- Restart FiJi; if you go on ´Help´-´Update...´ again, you should be prompted with a message "Your ImageJ is up to date!". If not, restart again.

# TeloScope

TeloScope was made to quantify telomere intensity signals from qFISH experiments. However, it is just as well suited to quantify other foci as long as they are in front of a background staining, such as nuclear staining (DAPI, etc.). Note: TeloScope was only tested on Windows 10.

## How to start TeloScope

- Open FiJi
- drag-drop the TeloScope.ijm file into FiJi
- in the window that now opened, click on run
- choose a folder where all your images are located and hit 'select'
- FiJi will load all pictures successively. For the first 5 pictures you will need to set parameters...

## The first picture

For the first picture there will be 2 points that you have to get right from the start:
- in which channel are the foci (telomeres) and in which channel is the background (nucleus)?
- how big are the foci? Zoom in with the mouse wheel or "+". When you are close enough, left-click and drag a circle over a telomere so that the entire telomere is in the circle. If you do not get it right the first time, just draw another circle (the first will disappear)

## The first 5 pictures

During the first 5 pictures FiJi will ask you to:
- set a threshold for the background. This can be especially important if you later want to distinguish cells in the analysis
- set the telomere sensitivity level

## Background correction

For every picture you will be asked to draw an area in the picture for the background correction. Next to that message and the actual picture will be a window with some sliders. It is recommended to use the second slider, shifting it to the right to see which areas still have background. When drawing the area, you should prefer those places that are darkest, even when the slider is far to the right.

## Output

The output is one csv file for each picture. Each row is a telomere. Although there are many columns, the most important ones are as follows.

- Label: image name and cell ID
- Area: The area of the telomere. This is important, because all telomereas should technically have the same area. A Telomere that has a different area than most should probably be discarded. These are often spots where telomeres where to close together. Take care to remove these rows in the analysis. Normally there are enough telomeres, so we can affort to lose a few bad apples.
- Mean: mean intensity value in the telomere
- Mode: modal intensity value (most occuring value) in the telomere
- Median: median intensity value in the telomere
- IntDen & RawIntDen: integrated density of the intensity values in the telomere

You will want to calculate telomere intensity with Mean, Mode, Median or IntDen. Before that, filter you telomeres by the area and group them based on sample and cell (i.e. the label column).

# cut_images

For some purposes it might be usefull to but the image before analyzing it. For example if you have an organ section but only want to measure telomere intensity in a certain area of that organ. With cut_images you can load all images and select the area you want to keep. This will be saved as a separate picture which you can than analyze with TeloScope

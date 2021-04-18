# TeloScope

TeloScope was made to quantify telomere intensity signals from qFISH experiments. However, it is just as well suited to quantify other foci as long as they are in front of a background staining, such as nuclear staining (DAPI, etc.).
Using TeloScope is simple IF you have all the prerequisites in you FiJi version. You will need the BioVoxxel plug-in to use TeloScope.

How to start TeloScope
- Open FiJi
- drag-drop the TeloScope.ijm file into FiJi
- in the window that now opened, click on run
- choose a folder where all your images are located and hit 'select'
- FiJi will load all pictures successively. For the first 5 pictures you will need to set parameters...

For the first picture there will be 2 points that you have to get right from the start:
- in which channel are the foci (telomeres) and in which channel is the background (nucleus)?
- how big are the foci? Zoom in with the mouse wheel or "+". When you are close enough, left-click and drag a circle over a telomere so that the entire telomere is in the circle. If you do not get it right the first time, just draw another circle (the first will disappear)

During the first 5 pictures FiJi will ask you to:
- set a threshold for the background. This can be especially important if you later want to distinguish cells in the analysis
- set the telomere sensitivity level

For every picture you will be asked to draw an area in the picture for the background correction. Next to that message and the actual picture will be a window with some sliders. It is recommended to use the second slider, shifting it to the right to see which areas still have background. When drawing the area, you should prefer those places that are darkest, even when the slider is far to the right.
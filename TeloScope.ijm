//set general settings for ImageJ
run("Options...", "iterations=1 count=1 black"); // sets up binary options
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=5")

//This script will load all images in a folder successively
//The first image will determine:
// 1) which channel is for telomeres and which is for DAPI
// 2) how big the telomere spots are
//The first 5 images will determine:
// 1) which threshold will be used
// 2) what sensitivity should be applied to find telomere foci
//In every image the user will have to make a background selection

//start counter, counting how many images are done (important to see what the first 5 images are)
firstImage = 1;

//the user chooses the directory
chosenDir = getDir("Choose a directory");
processFiles(chosenDir + File.separator); //calls the processFiles function, declared below
close("ROI Manager");
close("B&C");


function findNuclei(){
	run("Auto Threshold", "method="+threshold+" white");
	run("Watershed Irregular Features", "erosion=999 convexity_threshold=0 separator_size=0-Infinity");
	run("EDM Binary Operations", "iterations=9 operation=open");
	run("Analyze Particles...", "size=0-Infinity pixel circularity=0-1.00 exclude clear add");
}

function processFiles(myDir) {
	fileList = getFileList(myDir);

	//creation of outputfolder
	outdir = myDir + File.separator + ".." + File.separator + "analysis";
	outpath = outdir + File.separator;
	File.makeDirectory(outdir);
	
	//go through the files
	for (fileNumber = 0; fileNumber < fileList.length; fileNumber++) {
		file = fileList[fileNumber];
		if (endsWith(file, ".tif") || endsWith(file, ".png") || endsWith(file, ".czi")); {
			open(file);
			
//====================================================================================================================================
//what follows is done to all files. This is not written into an extra function because of changing variables that the user sets

//===============================================
//#==PART 0: prelude==#
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); // so everything is measured in pixel
getDimensions(width, height, cNum, zNum, tNum); //the variables can now be used (cNum=number of channels, zNum=number of slices, tNum=number of frames)
if(cNum < 2){exit("Less then 2 channels! Possibly channels are not recognized as such.")}

//USER defines what channel means what (only done on the first image)
if(firstImage==1){
Dialog.create("Define channels");
	Dialog.addNumber("Nuclei channel number: ",1);
	Dialog.addNumber("Foci channel number:",2);
	Dialog.show();
	//same sequence as in ADD!!!
	channelNumberNuclei=Dialog.getNumber();
	channelNumberFoci  =Dialog.getNumber();
}

//set variables for sample name and image names, then split into respective channels
name = getTitle();
nuclei = "C" + channelNumberNuclei + "-" + name;
foci = "C" + channelNumberFoci + "-" + name;
run("Split Channels");

//===============================================
//#==PART I: get the nuclei==#
selectWindow(nuclei);

//general enhancements to make the nuclei as clear to Fiji as possible
run("Pseudo flat field correction", "blurring=100 hide"); //even out intensity heterogeneity
run("Enhance Contrast...", "saturated=0.01 normalize");
run("Median...", "radius=10"); //gets rid of possible speckles inside the nuclei
run("8-bit");

//a list of all auto thresholds, to be used in the upcoming USER-CHECK
if(firstImage==1){threshold="Default";}
thresholdlist=newArray("Default","Huang","Huang2","Intermodes","IsoData","Li","MaxEntropy",
						"Mean","MinError(I)","Minimum","Moments","Otsu","Percentile",
						"RenyiEntropy","Shanbhag","Triangle","Yen");

//USER ckecks which threshold to use (this is done in the first 5 images)
//after the threshold is defined, the findNuclei() function is called (written in the beginning of the script) which applies the threshold and adds the nuclei to the ROI manager
//we also generate a binary nuclei image that is later used in the speckle inspector
if(firstImage<6){
	usercheck=0; //default, is the user satisfied with the threshold?
	while(usercheck==0){ //as long as the user doesn't tick the checkbox, this will be repeated with the selected threshold
		close("nucleiBW"); //doesn't exist in the first iteration
		selectWindow(nuclei);
		run("Duplicate...", "title=nucleiBW"); //this image will later be used in the speckle inspector (it will in the next line be thresholded)
		findNuclei(); //custom threshold function (also adds objects to the ROI manager)
			
		selectWindow(nuclei);
		roiManager("show all"); //shows the user the original nuclei image with the ROI manager outlines, generated from the thresholding

		//create a dialog where the user can specify the threshold
		Dialog.create("Threshold to define nuclei");
			Dialog.addChoice("Threshold:", thresholdlist, threshold);
			Dialog.addCheckbox("This threshold is acceptable", 0);
			Dialog.show();
		//read in the threshold and whether the user finds the threshold acceptable
			threshold=Dialog.getChoice();
			usercheck=Dialog.getCheckbox();
		//if the threshold was not yet acceptable delete all ROIs (and repeat the loop)
		if(usercheck==0){ roiManager("reset"); }
	}
}else{ //if the image is not one of the first 5, the last selected threshold will be used.
	run("Duplicate...", "title=nucleiBW");
	findNuclei();
}

//we have the nuclei ROIs, so the nuclei picture is no longer needed
close(nuclei);

//===============================================
//#==PART II: get the foci==#
//USER encircles a foci to get the rough size of them; necessary for rolling ball
selectWindow(foci);
run("Duplicate...", "title=fociBW");
selectWindow("fociBW");
if(firstImage==1){ //this is only done in the first image
	setTool("oval");
	while(!is("area")){
		waitForUser("Encircle one of the normal foci, then hit OK.\nYou can zoom in with [+].");
	}
	fociDiameter=(getValue("Width")+getValue("Width"))/2;
}
run("Select None");
rollingballDiameter=4*fociDiameter; //rolling ball to better find foci
run("Subtract Background...", "rolling="+rollingballDiameter);

//USER checks whether the parameter to define maxima is ok
if(firstImage<6){ //this is only done in the first 5 images
	run("Duplicate...", "title=temp"); //this is done to a temporary picture that is deleted afterwards
	waitForUser("Find a got spot to observe the foci!");
	if(firstImage==1){prominence=1000;} //in the first image, the default is 1000, afterwards it is the value last set by the user
	usercheck=0; //default, is the user satisfied with the prominence?
	while(usercheck==0){ //as long as the user doesn't tick the checkbox, this will be repeated with the selected prominence
		run("Find Maxima...", "prominence=" + prominence + " strict output=[Point Selection]");
	
		//create a dialog where the user can specify the prominence
		Dialog.create("Prominence to define maxima");
			Dialog.addNumber("Prominence >", prominence);
			Dialog.addCheckbox("This prominence is acceptable", 0);
			Dialog.show();
		//read in the prominence and whether the user finds the prominence acceptable
			prominence=Dialog.getNumber();
			usercheck=Dialog.getCheckbox();
		//delete the point selection
		run("Select None");
	}
	close("temp");
}

selectWindow("fociBW");
run("Find Maxima...", "prominence=" + prominence + " strict output=[Single Points]"); //apply the prominence as chosen by the user
dilations=(fociDiameter-1)/2; //number of dilations can be calculated if we know that we start from 1 pixel and how big the final foci should be
run("EDM Binary Operations", "iterations=" + dilations + " operation=dilate"); //dilate the 1-pixel maxima to match the foci size (set by the user earlier)
run("Watershed Irregular Features", "erosion=999 convexity_threshold=0 separator_size=0-Infinity"); //in case any foci merged, we watershed them. In R, we can delete foci with irregular sizes

// Background subtraction, done manually by the user for every image
selectWindow(foci);
run("Duplicate...", "title=temp");
run("Brightness/Contrast...");
setTool("freehand");
waitForUser("Background subtraction", "Please make a selection\nin the background and press ok.\nChange the second slider to see better!");
while(!is("area")){
	waitForUser("wrong selection");
}

selectWindow(foci);
run("Restore Selection");
backgroundIntensity=getValue("Mean"); //==getStatistics(area, backgroundIntensity)
run("Select None");
run("Subtract...", "value="+backgroundIntensity); //background subtraction

//use Biovoxxels speckle inspector. It uses the foci image with subtracted background and the binary images for nuclei and foci and generates a results table
run("Speckle Inspector", "primary=nucleiBW secondary=[fociBW Maxima] redirect="+foci+" show=none secondary_object");

//close all pictures
close("temp");
close("B&C");
close("nucleiBW");
close("fociBW");
close("fociBW Maxima");
close("Inspector of nucleiBW-1");
close(foci);

//save the results table for this sample
selectWindow("Roi Analysis");
saveAs("Results",  outdir + File.separator + name + ".csv"); 
close(name + ".csv"); //close the results table

//increase the counter for the imagenumber
firstImage++;
			
		}
	}
}



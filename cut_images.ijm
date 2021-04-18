// PART 0 - SETUP IMAGEJ
//setBackgroundColor(0, 0, 0); // makes the background black (important e.g. for clearing outside selection)
//setForegroundColor(255, 255, 255); // makes the foreground white
name = getTitle;
path = "D:\\Downloads\\"
getDimensions(width, height, cNum, zNum, tNum); //the variables can now be used (cNum=number of channels, zNum=number of slices, tNum=number of frames)

//-----------------------------------------------------------------------------------------------------
// PART 1 - save user selection as tiff

type = selectionType();
while(type==-1){ //if there was a ROI to begin with, nothing happens here...
	waitForUser("Select region(s) in DAPI channel!"); // ..otherwise the user is asked for a ROI
	type = selectionType();
}

if(zNum > 1){
	roiManager("Add");
	run("Select None");
	rename("Mirror");
	run("Duplicate...", "duplicate channels=1");
	run("Z Project...", "projection=[Sum Slices]");
	close("Mirror-1");
	roiManager("Select", 0);
	run("Make Inverse");
	run("Clear", "slice");
	run("Select None");

	selectWindow("Mirror");
	run("Duplicate...", "duplicate channels=2");
	run("Z Project...", "projection=[Max Intensity]");	
	close("Mirror-1");
	close("Mirror");

	selectWindow("MAX_Mirror-1");
	x = bitDepth();
	selectWindow("SUM_Mirror-1");
	y = bitDepth();
	if(x == y){;}
	else if(x == 16){run("16-bit");}
	else if(x == 8){run("8-bit");}
	else if(x == 24){run("24-bit");}
	else if(x == 32){run("32-bit");}
	run("Merge Channels...", "c3=SUM_Mirror-1 c7=MAX_Mirror-1 create");
	saveAs("Tiff","C:\\Users\\Bus Driver\\Documents\\"+name+".tif"); // saving as .tif is necessary to preserve all the channels
	close(); 	
	roiManager("Delete");
	} else {
		run("Make Inverse");
		run("Clear", "slice"); // do not use "run("Clear Outside")"; this would ask the user if it should be done on all channels
		run("Select None");
		saveAs("Tiff",path+name+"_cut.tif"); // saving as .tif is necessary to preserve all the channels
		close(); 
	}
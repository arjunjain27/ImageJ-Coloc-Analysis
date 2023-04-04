// READ ME
// This script takes two-channel images of cells or other particles of interest and determines what % of the cells signalled in
// the first channel also have signal in the second channel.
// For example, channel 1 =  DAPI and channel 2 = cFOS. The script would determine what % of DAPI-stained cells also stained with cFOS.

// Before using this script, images from both channels should be in one folder
// Image IDs for each channel should be identical except for a channel identifier at the end of the image name
// Example:
// Image1_ch0.tif
// Image1_ch1.tif

// prompts user to choose folder with images
dir = getDirectory("Choose directory: ");
files = getFileList(dir);

// retrieves and formats today's date
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
date = "" + year;
month = month + 1;
if (month < 10) {date = date + "0";}
date = date + month;
if (dayOfMonth < 10) {date = date + "0";}
date = date + dayOfMonth;

// creates a folder within the image folder to save results
// folder name includes today's date
resultsDir = dir + "Fiji Results - " + date + "/";
File.makeDirectory(resultsDir);

// prompts user to enter the channel identifiers at the end of the image names
ch0_id = getString("Enter the identifier for the first channel at the end of each image name (e.g. ch00): ", "ch00");
ch1_id = getString("Enter the identifier for the second channel at the end of each image name (e.g. ch01): ", "ch01");

// creates sub-folders within results folder to save different data
ROIDir = resultsDir + ch0_id + " ROIs/";
countsDir = resultsDir + ch0_id + " counts/";
colocsDir = resultsDir + ch0_id + " colocs/";
File.makeDirectory(ROIDir);
File.makeDirectory(countsDir);
File.makeDirectory(colocsDir);

ch0_id = ch0_id + ".tif";
ch1_id = ch1_id + ".tif";

// this for loop iterates through all the images within the chosen folder one by one
for (i = 0; i < files.length; i++)
{
	imgDir = files[i];

	// this if statement identifies which channel the current image is
	if (endsWith(imgDir, ch0_id))
	{
		ch00_dir = imgDir;
		ch01_dir = replace(imgDir, ch0_id, ch1_id);
	}
	else
	{
		continue
	}

	// opens the image in the first channel
	open(dir + ch00_dir);
	imgName = getTitle();
	imgName = replace(imgName , ".tif" , "");
	summName = imgName + "_summ.csv";
	ROIName = imgName + "_ROI.zip";

	// pre-processing
	run("Invert");
	run("Maximum...", "radius=2");
	setAutoThreshold("Default");
	setOption("BlackBackground", false);
	run("Convert to Mask");

	// counts cells and saves ROIs to results folder
	run("Analyze Particles...", "size=5-500 show=Overlay display exclude summarize add");
	saveAs("Results", countsDir + summName);
	roiManager("Save", ROIDir + ROIName);
	close();

	run("Clear Results");
	roiManager("reset");

	// opens the image in the second channel
	open(dir + ch01_dir);
	dataName = imgName + "coloc.csv";

	// pre-processing
	run("Invert");
	setAutoThreshold("Default");
	setOption("BlackBackground", false);
	run("Convert to Mask");

	// opens the first channel cell ROIs
	run("Set Measurements...", "mean redirect=None decimal=2");
	run("ROI Manager...");
	roiManager("Open", ROIDir + ROIName);
	ROIs = roiManager("Count");

	// creates array to store whether ROI colocalizes (0 or 1)
	colocBin = newArray(ROIs);

	// this for loop iterates through the first channel ROIs with the second channel open
	for (j = 0; j < ROIs; j++)
	{
		roiManager("Select", j);

		// determines whether ROI colocalizes with second channel signal
		run("Close-");
		run("Measure");
		mgv = getResult("Mean", nResults-1);
		if (mgv > 127.5)
		{
			colocBin[j] = 1; // if colocalized, change corresponding array value to 1
		}
	}

	// saves measurements to results folder
	saveAs("Results", colocsDir + dataName);
	close();

	// prints image ID and % colocalization to log
	Array.getStatistics(colocBin, min, max, mean, std);
	print(ch00_dir);
	print(mean);

	run("Clear Results");
	roiManager("reset");
	close("*summ.csv");
} 
// end of for loop (all images in folder processed)

// retrieves data from log
logData = getInfo("log");
logData = split(logData,"\n");
selectWindow("Log"); 
run("Close");

// reformats the log data into two arrays of IDs and colocalization %s
colocs = newArray((logData.length)/2);
ids = newArray((logData.length)/2);

for (i = 0; i < logData.length; i++)
{
	if (i%2 == 0)
	{
		ids[i/2] = logData[i];
	}
	else
	{
		colocs[((i-1)/2)] = logData[i];
	}
}

// creates and formats a table from the two arrays
Table.create("Final Results");
Table.setColumn("Image", ids);
Table.setColumn("% Colocalized", colocs);
Table.setLocationAndSize(400, 400, 400, 400);

// saves the table as a .csv file in the results folder with the current date
Table.save(resultsDir + "Fiji Coloc Results - " + date + ".csv");

selectWindow("Results"); 
run("Close");
selectWindow("ROI Manager");
run("Close");

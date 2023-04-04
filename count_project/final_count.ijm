
dir = getDirectory("Choose directory: ");
files = getFileList(dir);
resultsDir = dir + "Results/";
File.makeDirectory(resultsDir);

for (i = 0; i < files.length; i++)
{
	imgDir = files[i];

	open(dir + imgDir);
	imgName = getTitle();
	imgName = replace(imgName , ".tif" , "");
	summName = imgName + "_summ.csv";
	ROIName = imgName + "_ROI.zip";
	run("Invert");
	setAutoThreshold("Default");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size=30-500 show=Overlay display summarize add");
	saveAs("Results", resultsDir + summName);
	roiManager("Save", resultsDir + ROIName);
	nROIs = roiManager("count");
	print(imgDir);
	print(nROIs);
	close();

	run("Clear Results");
	roiManager("reset");
}

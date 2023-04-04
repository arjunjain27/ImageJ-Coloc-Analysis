// READ ME
// This script takes images with two channels with channel identifiers in their names and moves those identifiers to the
// end of the image names, saving the renamed images in a folder.
// The colocalization script can then be used on the renamed images folder.

// prompts user to choose folder with images
dir = getDirectory("Choose directory: ");
files = getFileList(dir);

// creates a folder within the image folder to save the renamed images
resultsDir = dir + "Fiji Renamed Images/";
File.makeDirectory(resultsDir);

// prompts user to enter the channel identifiers in the image names
ch0_id = getString("Enter the identifier in the image name for the first channel (e.g. ch00): ", "ch00");
ch1_id = getString("Enter the identifier in the image name for the second channel (e.g. ch01): ", "ch01");

// this for loop iterates through all the images within the chosen folder one by one
for (i = 0; i < files.length; i++)
{
	imgDir = files[i];

	// this if statement identifies which channel the current image is
	if (indexOf(imgDir, ch0_id) >= 0)
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

	// retrieves the image name and moves the channel identifier to the end
	imgName = getTitle();
	newName = replace(imgName, ch0_id, "");
	newName = replace(newName, ".tif", "_" + ch0_id);

	// saves the renamed image in the results folder
	saveAs("Tiff", resultsDir + newName);
	close();

	// repeats process with image in second channel
	open(dir + ch01_dir);
	imgName = getTitle();
	newName = replace(imgName, ch1_id, "");
	newName = replace(newName, ".tif", "_" + ch1_id);
	saveAs("Tiff", resultsDir + newName);
	close();
}
dir = getDirectory("Choose directory: ");
files = getFileList(dir);
max_c1 = dir + "new MAX_C1 DAPI/";
max_c2 = dir + "new MAX_C2 TH/";
max_c3 = dir + "new MAX_C3 cFOS/";
File.makeDirectory(max_c1);
File.makeDirectory(max_c2);
File.makeDirectory(max_c3);

for (i = 0; i < files.length; i++)
{
	img = files[i];
	saveName =  replace(img, ".tif" , "");
	open(dir + img);
	run("Split Channels");

	c1dir = "C1-" + img;
	c2dir = "C2-" + img;
	c3dir = "C3-" + img;

	selectWindow(c1dir);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", max_c1 + "C1_" + saveName);
	close();

	selectWindow(c2dir);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", max_c2 + "C2_" + saveName);
	close();

	selectWindow(c3dir);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", max_c3 + "C3_" + saveName);
	close("*");
}

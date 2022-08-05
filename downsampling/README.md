# Python script that downsamples the signal.
In order to run, it is necessary to add in the same location of the script a 'files.txt' file. 
The first row of the file is going to be either 'presleep' or 'postsleep'. This ensures that the length of the signal
is going to be correct (4hrs for post, 1hrs for presleep).
All the other lines of the file are the paths to the .mda files you desire to downsample. NOTE: the path has to end with
'.mountainsort'

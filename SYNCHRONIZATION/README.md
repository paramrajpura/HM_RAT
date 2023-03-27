## Synchronization files
For the LED ICA extraction there are some older versions from which the newest script was based on. 
The newest script is the Extract_LEDs_28_01_2023.ipynb.

# - Extract_LEDs (1).ipynb: 
Oldest version, has missing YUV and HSV methods

# - Extract_LEDs_28_01_2023.ipynb:
Newest version. This is the file that should be worked on.


# - Extract_LEDs_0519.ipynb:
If I'm not mistaken there was a LED that had a problema when trying to apply ICA so it needed a little polishing for tat specific lED.


# - synch_editedbyOzge.py:
This files is based on the synchronization script, this is where the synchronization of the video and ephys should happen taking into account the results from the LED extraction files and the scripts needed for the synchornization from the ephys part

# - synchronization.py:
Older versrion from which synch_editedbyOzge.py was based on.


## Needed files to run the scripts
The files needed to run the Exctract_LEDs_28_01_2023.ipynb are the videos found at /media/genzel/Data/Hexmaze/maze_videos on Ireland pc

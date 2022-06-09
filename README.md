Dependencies: To-add. 


# Hexmaze Rat scripts
Repository for Hexmaze Rat project. 

## Main scripts: :file_folder: 

_**Data preprocessing:**_ 

  * filename1.m

_**Sleep stages analysis:**_ 
  
  * filename2.m  
 
_**Event detection:**_ 
  
  * filename3.m 

### Spikesorting scripts: :file_folder: 

_**Square Shape Artefact removal:**_ 
  
  * Preprocessing_squareArtefact.py 

This file will performe concatenation and removal of the "square shape artefact". Depending on the size of the files it use a lot of memory usage.

File to preprocess should be in 3 different Folder :
  * mda_extracted_presleep
  * mda_extracted_maze
  * mda_extracted_postsleep

Each folder the mda extraction from trode of the files.

The script will ask : the directory of those folder, which rat, on what study day and the TNU number of the rat.

It will create a new folder named preprocess with the concated and preprocess file in it group by rat and studyday.


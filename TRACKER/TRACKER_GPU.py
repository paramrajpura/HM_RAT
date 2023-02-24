import tensorflow as tf
'''
tf.test.is_gpu_available(
    cuda_only=False, min_cuda_compute_capability=None
)
'''
tf.config.list_physical_devices('GPU')
#tf.test.gpu_device_name()

print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))



##Clone GitHub repository with Tracker script and files 
#!git clone https://github.com/GiuliaP96/TrackerColab.git  

##Connect to your google drive account, follow instruction that appear in the cell below
##>> choose your Google account >> sign in >> copy link though the botton >> paste it below >> press enter
#from google.colab import drive                            
#drive.mount('/content/drive') 
#!ln -s  /content/drive/My\ Drive/ /mydrive  
#!ls /mydrive

##Install packages needed to extract file in .rar and run the tracker

##Extract model weights file 
from pyunpack import Archive                              
#Archive('Location of the rar file').extractall('Location where you want to have the folder') 
Archive('/home/genzel/Desktop/TRACKER/tracker/ModelWeights.rar').extractall('/home/genzel/Desktop/TRACKER/tracker/trackerC') 
###>>> Archive('/content/drive/MyDrive/TrackerTools.rar') path may changed if .rar file is placed in another folder e.g. /content/drive/MyDrive/YourFolderName/TrackerTools.rar


##### Run the tracker. Format -i path of video input to be tracked, -o path to folder /logs and /videos in Google drive
%cd /home/genzel/Desktop/TRACKER/tracker/TrackerColab
!python /home/genzel/Desktop/TRACKER/tracker/TrackerColab/TrackerYolov3-Colab.py -i /home/genzel/Desktop/TRACKER/tracker/stitched.mp4 -o /home/genzel/Desktop/TRACKER/tracker 

####can be changed e.g. /content/drive/MyDrive/YourFolderName [other folders paths will be /content/drive/MyDrive/NameofyourFolder/logs and /content/drive/MyDrive/NameofyourFolder/videos]



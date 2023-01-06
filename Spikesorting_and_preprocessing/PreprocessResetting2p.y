import os, sys, json
import numpy as np
import pandas as pd
from mountainlab_pytools import mdaio
import copy
import multiprocessing as mp
import time
from timeit import default_timer as timer
from multiprocessing import Pool, cpu_count
import pathlib
import numba
from numba import jit


def concat(pre_directory,maze_directory,post_directory):
    # function for the concatenation
    # Input :
    # pre_directory , maze_directory, post_directory are path to the
    # mda file of respectevily presleep,maze,postleep recording
    # Output :
    # Numpy Array of the truncated mda recording
    presleep = mdaio.readmda(pre_directory)
    maze = mdaio.readmda(maze_directory)
    postsleep = mdaio.readmda(post_directory)
    presleep = presleep[:,:108000000]
    maze = maze[:,:108000000]
    postsleep = postsleep[:,:108000000*4]
    rec = np.concatenate((presleep,maze,postsleep),axis=1)

    return rec

@jit(nopython=True)
def art(rec,a):
    # function for the concatenation
    # Input :
    # rec numpy array of the recording
    # Output :
    # Numpy Array with the resetting artefact removed
    rec = rec[:,:108000000*a]
    rec = np.transpose(rec).astype(np.int16)
    for j in range(4):
        for i in range(rec.shape[0]-1):
            if(i!= rec.shape[0]):
                m = (rec[i+1,j]-rec[i,j])
                flag = 0
                if (m>30000):
                    flag=1
                elif (m<-30000):
                    flag=0
                while(flag==1):
                    rec[i+1,j]=-32767
                    break;
    rec = rec.transpose()
    return rec
    



def main():
    directory = input("Enter the directory: ") # Directory path there should be 3 folder in the directory
                                               # mda_extracted_postleep mda_extracted_maze mda_extracted_presleep
    print(directory)
    rat = input("Enter the rat (ex : Rat1): ") # enter the rat number for the preprocessing
    studyday = input("Enter the StudyDay: ") # enter the STUDYDAY for the preprocessing
    number = input("Enter the TNU number : ") # enter the TNU number for the preprocessing (different from rat to rat)
    wake = input("Enter (wake or Maze) : ") # Enter if the maze recording is wake or maze recording
    print('wake: ', wake)
    presleep = directory+'/mda_extracted_presleep'+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_presleep.mountainsort/'
    print("presleep:",presleep)
    maze = directory+'/mda_extracted_maze'+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+wake+'.mountainsort/'
    print("maze:",maze)
    postsleep = directory+'/mda_extracted_postsleep'+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_postsleep.mountainsort/'
    print('postsleep:',postsleep)
    
    # making sure that the postsleep path exist
    if os.path.exists(postsleep): # gathering of all of the tetrode
        #deffinition of the output
        output='/media/genzel/Elements/hm_spikesorting/Preprocess/'+rat+'_'+studyday+'/'
        listtetrode = []
        start = timer()
        print('output:',output)
 

#use this part if you want to preprocess the files in the following path: cand put in comment the other part
       # cheking all the folders in the postsleep directory
#=============================================================================
        # for filename in os.listdir(postsleep):       
        #     print('filename:',filename) 
        #     #adding the folder of the postsleep directory to the path named f
        #     f = os.path.join(postsleep, filename)
        #         #fo each files in the f directory
        #     for file in os.listdir(f):  
        #           print('file:',file)
        #           #.mda
        #           extension = file[-4:] 
        #           #timestamps.mda
        #           check = file[-14:] 
        #           #name of the file without the .mda
        #           name = file[0:-4]              
        #           start = timer()
#=============================================================================
                
               
 #use this part if you want to preprocess files in other path and put in comment the other part         
        # only path      
#=============================================================================
        for file in os.listdir(postsleep):  
            print('file:', file)   
            extension = file[-4:]  
            check = file[-14:]  
            name = file[0:-4] 
            start = timer() 
                           
 #=============================================================================               
            if extension == '.mda' and check != 'timestamps.mda':
                    tet = file[44:-4]
                    listtetrode.append(tet)
                    listtetrode = list(set(listtetrode))
                    #print ('liste tetrode:',listtetrode)
                    
        for tetrode in listtetrode:
            print('tetrode:',tetrode)
            if not os.path.exists(output):
                    os.makedirs(output)
            presleepDir = presleep+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_presleep.'+tetrode+'.mda'
            presleepmda = mdaio.readmda(presleepDir)
            #propredir = output+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+wake+'_'+tetrode+'_Preprocess_presleep'
            pre = art(presleepmda,1)
            #mdaio.writemda16i(pre,propredir+'.mda')
       
            print('maze')
            #mazeDir = maze+studyday+'_Rat_01.'+tetrode+'.mda'
            mazeDir = maze+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+wake+'.'+tetrode+'.mda'
            mazemda = mdaio.readmda(mazeDir)
            #promazedir = output+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+wake+'_'+tetrode+'_Preprocess_maze'
            ma = art(mazemda,1)
            #mdaio.writemda16i(ma,promazedir+'.mda')
        
            print('post')
            #postsleepDir = postsleep+'/StudyDay'+studyday+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_postsleep.'+tetrode+'.mda' #for the files in the genzel server
            postsleepDir = postsleep+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_postsleep.'+tetrode+'.mda'
            postsleepmda = mdaio.readmda(postsleepDir)
            #propostdir = output+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+wake+'_'+te/mnt/genzel/Rat/HM/Rat_HM_Ephystrode+'_Preprocess_postsleep'
            post = art(postsleepmda,4)
            print('post:',post)
            #mdaio.writemda16i(post,propostdir+'.mda')
           
            print('Concat')
            recording = np.concatenate((pre,ma,post),axis=1)
            mdaio.writemda16i(recording,output+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+wake+'_'+tetrode+'_Preprocess.mda')
            end = timer()  
            del pre
            del ma
            del post
            del recording
            print(f'elapsed time: {end - start}')
            print('file preprocess:'+rat+'_'+number+'_'+studyday+'_'+wake)
    else: 
        print("the path postsleep doesn't exist")
   
if __name__ == '__main__':
    main()
                        
        

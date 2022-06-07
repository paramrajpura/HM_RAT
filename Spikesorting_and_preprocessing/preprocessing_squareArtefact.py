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

def slope(channel):
    m = (channel[1]-channel[0])
    if (m == 0 or m>30000 or m<-30000) and (channel[1]<-30000 or channel[1] == 0):
        flat = -32767
    else:
        flat = channel[0]
    return flat


def concat(pre_directory,maze_directory,post_directory):
    presleep = mdaio.readmda(pre_directory)
    maze = mdaio.readmda(maze_directory)
    postsleep = mdaio.readmda(post_directory)
    presleep = presleep[:,:108000000]
    maze = maze[:,:108000000]
    postsleep = postsleep[:,:108000000*4]
    rec = np.concatenate((presleep,maze,postsleep),axis=1)
    del presleep
    del maze
    del postsleep
    return rec

def remove(rec,directory_output):
    rec = np.transpose(rec).astype(np.int16)
    recording = pd.DataFrame()
    for j in range(4):
        ch1 = rec[:,j]
        ych1 = copy.deepcopy(ch1)
        rem1 = np.delete(ych1 , 0)
        rem1 = np.append(rem1,0)
        ch1 = pd.DataFrame(ch1)
        ch1['copy']= rem1 
        ch1 = ch1.astype(int)
        ch1 = ch1.to_numpy()
        del rem1
        del ych1
        ch1 = map(slope,ch1)
        ch1 = pd.DataFrame((list(ch1)))
        recording = pd.concat([recording,ch1], axis=1).astype(np.int16)
    
    recording = recording.to_numpy()    
    recording = recording.transpose()
    mdaio.writemda16i(recording,directory_output+'.mda')
    del recording

directory = input("Enter the directory: ")
print(directory)



def main():
    # listrat = []
    # liststudyday = []
    # listperiod = []
    # listnum = []
    # for filename in os.listdir(directory):
    #     f = os.path.join(directory, filename)
    #     # checking if it is a file
    #     ratnb = filename[13:17]
    #     num = filename[18:24]
    #     studydaynb = filename[25:33]
    #     periodnb = filename[34:43]
    #     listrat.append(ratnb)
    #     listnum.append(num)
    #     liststudyday.append(studydaynb)
    #     listperiod.append(periodnb)
    #     listrat = list(set(listrat))
    #     listnum = list(set(listnum))
    #     liststudyday = list(set(liststudyday))
    #     listperiod = list(set(listperiod))
    rat = input("Enter the rat (ex : Rat1): ")
    studyday = input("Enter the StudyDay: ")
    number = input("Enter the TNU number : ")
    presleep = directory+'/mda_extracted_presleep'+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_presleep.mountainsort/'
    maze = directory+'/mda_extracted_maze'+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_Maze_merged.mountainsort/'
    postsleep = directory+'/mda_extracted_postsleep'+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_postsleep.mountainsort/'
    
    if os.path.exists(postsleep):
        output = directory+'/Preprocess/'+rat+'_'+studyday+'/'
        listtetrode = []
        start = timer()

        for filename in os.listdir(postsleep):
            print(filename)
            f = os.path.join(postsleep, filename)
            extension = f[-4:]
            check = f[-14:]
            name = filename[0:-4]
            if os.path.isfile(f):
                start = timer()
                if extension == '.mda' and check != 'timestamps.mda':
                    f = os.path.join(directory, filename)
                    tet = filename[44:-4]
                    listtetrode.append(tet)
                    listtetrode = list(set(listtetrode))
        for tetrode in listtetrode:
            print(tetrode)
            presleepDir = presleep+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_presleep.'+tetrode+'.mda'
            mazeDir = maze+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_Maze_merged.'+tetrode+'.mda'
            postsleepDir = postsleep+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_postsleep.'+tetrode+'.mda'
            recording = concat(presleepDir,mazeDir,postsleepDir)
            print('Concat')
            if not os.path.exists(output):
                    os.makedirs(output)
            remove(recording,output+'/Rat_Hm_Ephys_'+rat+'_'+number+'_'+studyday+'_'+tetrode+'_Preprocess')
            end = timer()  
            print(f'elapsed time: {end - start}')
   
if __name__ == '__main__':
    main()
                        
        
import os
import sys
import csv
from subprocess import call

def matlabExec(mls):
    """Call MatLab from command line and execute script given by mls"""
    if(str(mls).split(.)[-1]!= 'm'):
        print "Not a valid Matlab file"
        return
    else:
        call("matlab -r" + str(mls))

def getMFCC(t):
    """Read text file and get mfccs of the song. Return a string of values"""
    newinstance = str(t)
    mfcc = []
    with open(newinstance,"r") as csvf:
        mfccReader = csv.reader(csvf,delimiter=',')
        for row in mfccReader:
            for col in row:
                coln = float(col)
                mfcc.append(coln)
    return mfcc

def getTrainingMFCC(o):
    "Get training MFCC data. Return a list of list with inner list representing each song"
    mfccreaderold = csv.reader('training.csv')
    trainingdata = str(o)
    mfcclist = []

    with open(trainingdata,"r") as csvf:
        mfccReader = csv.reader(csvf,delimiter=',')
        for row in mfccReader:
            mfcclist.append(row)

    return mfcclist

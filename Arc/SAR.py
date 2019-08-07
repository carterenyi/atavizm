import pandas as pd
import numpy as np

def SAR_Contour(nmat, s_type=3, cmin=5, cmax=10, degrees=2):
    """Finds the unique patterns to be displayed and creates a structure to hold all the information needed to plot."""
    pitches=list(nmat['Pitch']) #Get the list of pitches for the piece
    contcom = _make_ContCM(pitches,degrees) #convert to continuous contour matrix
    CL = np.nansum(contcom, axis=0) #get the sums of the columns of the matrix
    
    if s_type > 1:
        durs=list(nmat['Time']) #extract beat onsets as a list
        durs=[x-y for x,y in zip(durs[1:len(durs)-1],durs[0:len(durs)-2])] #convert to interonset durations by subtracting adjacent onsets
        durs.append(nmat['Duration'].iloc[-1]) #add the duration of the last note back to list
        contcom=_make_ContCM(durs,degrees) #create continuous contour matrix
        DCL = np.nansum(contcom, axis=0) #get the sums of the columns of the matrix
        
    if s_type == 1:
        CL_list = [CL, CL]
    elif s_type == 2:
        CL_list = [DCL, DCL]
    elif s_type == 3:
        CL_list = [CL,DCL]
    
    p = _get_segments(cmin,cmax,pitches,CL_list) #makes a dataframe of all the important segments needed
    
    #initialize storage variables
#     allcov = []
    r = pd.DataFrame(columns=['card','seg','segcount','segind','cov','invind'])
    
    for i in range(0,len(p)):
        for j in range(0,len(p[i]["seg"])):
            r = r.append({"card":len(p[i]["seg"][j]),
                  "seg":p[i]["seg"][j],
                  "segcount":p[i]["segcount"][j],
                  "segind":p[i]["segind"][j],
                  "cov":p[i]["segcov"][j],
                  "invind":[]}, ignore_index=True)
#             allcov.append(p[i]["segcov"][j])

    r = r.sort_values(by=["cov"], ascending=False).reset_index(drop=True)

    s = []

    for i in range(0,len(r)):
        inds=[]
        for j in range(0,len(r["segind"].iloc[i])):
            a=r["segind"].iloc[i][j]
            b=r["segind"].iloc[i][j]+r["card"].iloc[i]-1
            temp=list(range(a,b))
            inds=inds+temp
        s.append(inds)
        
    r["inds"] = pd.Series(s, index=r.index) 
    
    for i in range(len(r)-1,1,-1):
        b=r["inds"].iloc[i]
        for j in range(0,i-1):
            a=r["inds"].iloc[j]
            if set(b).issubset(set(a)):
                r.drop(r.index[i], inplace=True)
                break
                
    r = r.sort_values(by=["cov"], ascending=False).reset_index(drop=True)
    
    return {"r":r, "p":p, "CL":CL_list, "nmat":nmat}

def _get_segments(cmin,cmax,pitches,CL_list):
    """returns a list containing the, at max, 5 unique pattern of notes that occur most frequently for every pattern length.
        i.e. the list looks like [(patterns of length 5), (patterns of length 6), (patterns of length 7), ...]"""
    p = []
    for n in range(cmin,cmax): #this should be a range of cardinalities to look over
        segments = [CL_list[0][i:i+n] for i in range(0, len(pitches)-n)] #get list of all possible segments of n cardinality
        segmentu = [list(x) for x in set(tuple(x) for x in segments)] #get the unique segments from the list

        segind = [[] for i in range(0,len(segmentu))] #get the index of these occurences of these segments, this also happens to be the index of the notes they start on
        for i in range(0,len(segmentu)):
            for j in range(0,len(segments)):
                if (segments[j] == segmentu[i]).all():
                    segind[i].append(j)

        if len(segments) == len(segmentu):
            break
        
        segmentucount = np.array([len(x) for x in segind]) #get a count of all the occurences for a given segment
#         segmentpitch = [pitches[ind[i][0]-2:ind[i][0]+n-1+2] for i in range(len(ind))] #get the pitches of the original occurence

        max_ind = np.argsort(segmentucount)[::-1][:5] #the indexes of the 5 most frequent segments so that the largest is in front
        max_segmentu = np.array(segmentu)[max_ind]
        max_segmentucount = segmentucount[max_ind]
#         max_segmentpitch = np.array(segmentpitch)[max_ind]
        max_segmentucov = [i*n for i in max_segmentucount]
        max_segind = np.array(segind)[max_ind]

        p.append({"segments":segments,
                  "seg":max_segmentu,
                  "segcount":max_segmentucount,
                  "segind":max_segind,
                  "segcov":max_segmentucov}) #storing the results in a data structure for later (will have index n-1)
    return p
    
def _make_ContCM(arr, deg1, deg2 = None):
    """
    Creates Continous Contour Matrix for searching
    Adapted for asynchrony
    """
    
    if deg2 is None:
        deg2 = deg1
    
    degrees = deg1 + deg2
    ContCM = np.zeros((degrees,len(arr))) #creates and initializes  contour matrix w/ zeroes
    ContCM.fill(np.nan)            #fills matrix with Null values
    for n in range(0,len(arr)):    
            for i in [1,2]:
                try:
                    if arr[n] > arr[n-i] and n-i >= 0 :
                        ContCM[deg1-i, n] = 1
                    elif n-i >= 0:
                        ContCM[deg1-i, n] = 0
                except:
                    continue

            for i in [1,2]:
                try:
                    if arr[n] > arr[n+i]:
                        ContCM[deg1+i-1, n] = 1
                    else:
                        ContCM[deg1+i-1, n] = 0
                except:
                    continue
    
    return ContCM
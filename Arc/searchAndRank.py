import midi2nmat
import numpy as np

def _make_ContCM(arr, deg1, deg2 = None):
    """
    Creates Continous Contour Matrix for searching
    Adapted for asynchrony
    """
    
    if deg2 is None:
        deg2 = deg1
    
    degrees = deg1 + deg2
    ContCM = np.zeros((deg1,deg2)) #creates and initializes  contour matrix w/ zeroes
    ContCM.fill(np.nan)            #fills matrix with Null values
    
    for n in range(0,len(arr)):
        try:    
            for j in range(0,deg1):
                if arr[n] > arr[n-j]:
                    ContCM[deg1-j, n] = 1
                else:
                    ContCM[deg1-j, i] = 0
        except:
            continue
        
        try:
            for j in range(0,deg2):
                if arr[n] > arr[n+j]:
                    ContCM[deg1+j, n] = 1
                else:
                    ContCM[deg1+j, n] = 0
        except:
            continue
    
    return ContCM
    
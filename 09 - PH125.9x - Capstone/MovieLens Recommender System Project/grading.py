#!/usr/bin/env python

import pandas as pd

submission = pd.read_csv('submission.csv') # Learner's submission File
rubric = pd.read_csv('rubric.csv') # Rubric from edX


# If the learner's answer equal to rubric in each row, get 1 points

Score=[]
matches=0
for x,y in zip(submission.rating, rubric.rating):
    if x == y: 
        matches += 1

# Calculate the final grade for accuracy to 4 decimal places
 
Score.append(round(matches/rubric.shape[0],4)) 
   
print('The accuracy for this learner is', Score[0]*100.00)
Lots of code here has been built on guidelines provided by Samuel Evans (UCL, now Westminster). All mistakes however, are likely to be mine. 

This script allows you to present sentences or fixation crosses. It will wait for 2 seconds and then move on to the next sentence, or you can hit a button to make it go faster.

To use this script, you will need to create two directories within your 'SentReading' folder, 'Logs' and 'Onsets'
These can be done by easily typing 
```matlab
mkdir('Logs');
mkdir('Onsets');
```

To change the sentences, go to Sentences.m, type in new Sentences and then run this script.

You can demo the MRI mode on a personal computer, for now the key '5%' is assigned to be the trigger. This may change.

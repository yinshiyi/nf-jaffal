This is a nextflow implemntation of JAFFAL (https://github.com/Oshlack/JAFFA/blob/master/JAFFAL.groovy)
I tested using LongReadFusionSimulation dataset.

Launch by setting these 5 parameters
```
nextflow main.nf   \
    --JAFFA_path  {user_path} \
    --genomeFasta {user_path} \
    --transFasta  {user_path} \
    --transTable  {user_path} \
    --fastq       {user_path}
```

#$ -S /bin/bash
#$ -N myjob
#$ -cwd                                      # Run job from current directory

#$ -q serial
#$ -l h_vmem=16G                                # Request  16 GB of virtual memory, MATLAB needs at least 8GB to launch

###$ -m e
###$ -M m.tso@lancaster.ac.uk

source /etc/profile

export TERM=xterm

module add wine
module add matlab

wine64 ../cR2.exe
#matlab -nodisplay -nosplash -nodesktop -r "run('EKI.m');exit;"


